using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Net;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Web;
using System.Web.Configuration;

namespace InternshipManagementSystem.Data
{
    // Synchronous Firebase REST calls with one token refresh per request.
    //
    // Speed: every Firebase call is a trip over the internet (about 0.2 s), so
    // reads are remembered for a few seconds (Firebase.ReadCacheSeconds in
    // Web.config) and Prefetch can run several reads at the same time.
    // The cache is kept per signed-in user (their own token), so database
    // rules still decide what each person can read, and ANY write made by
    // this app empties it, so a page always shows its own changes at once.
    public static class FirebaseContext
    {
        public static string DatabaseUrl
        {
            get
            {
                string value = WebConfigurationManager.AppSettings["Firebase.DatabaseUrl"];
                return string.IsNullOrWhiteSpace(value) ? null : value.TrimEnd('/');
            }
        }

        public static string ApiKey
        {
            get { return WebConfigurationManager.AppSettings["Firebase.ApiKey"]; }
        }

        public static bool IsConfigured
        {
            get { return !string.IsNullOrEmpty(DatabaseUrl) && !string.IsNullOrEmpty(ApiKey); }
        }

        /// <summary>The signed-in user's Firebase ID token, when there is one.
        /// Sent as ?auth= so database rules can identify the caller.</summary>
        private static string CurrentToken()
        {
            if (HttpContext.Current == null || HttpContext.Current.Session == null) return null;
            return HttpContext.Current.Session[Common.Constants.SessionTokenKey] as string;
        }

        private static string BuildUrl(string path, string query)
        {
            if (!IsConfigured)
            {
                throw new InvalidOperationException(
                    "Firebase is not configured. Set Firebase.DatabaseUrl and Firebase.ApiKey " +
                    "in Web.config. See docs/05-firebase-setup.md.");
            }

            StringBuilder url = new StringBuilder();
            url.Append(DatabaseUrl).Append('/').Append(path.Trim('/')).Append(".json");

            List<string> parts = new List<string>();
            if (!string.IsNullOrEmpty(query)) parts.Add(query);

            string token = CurrentToken();
            if (!string.IsNullOrEmpty(token)) parts.Add("auth=" + Uri.EscapeDataString(token));

            if (parts.Count > 0) url.Append('?').Append(string.Join("&", parts.ToArray()));
            return url.ToString();
        }

        /// <summary>Reads a node. Returns null when the node does not exist.</summary>
        public static string Get(string path)
        {
            return Read(path, null);
        }

        /// <summary>Reads children of <paramref name="path"/> whose
        /// <paramref name="field"/> equals <paramref name="value"/>.
        /// Uses the field's .indexOn rule (docs/05-firebase-setup.md). If the rule
        /// is missing, reads the whole node and filters here so the page still loads.</summary>
        public static string GetWhere(string path, string field, string value)
        {
            string query = WhereQuery(field, value);
            try
            {
                return Read(path, query);
            }
            catch (FirebaseException ex)
            {
                if (ex.Message.IndexOf("Index not defined", StringComparison.OrdinalIgnoreCase) < 0) throw;
                System.Diagnostics.Trace.TraceWarning(
                    "Firebase index missing: add \".indexOn\": \"" + field + "\" to /" + path.Trim('/') + ". Filtering locally.");
                return FilterChildren(Get(path), field, value);
            }
        }

        private static string FilterChildren(string json, string field, string value)
        {
            if (json == null) return null;
            Dictionary<string, object> all = Json.ToMap(json);
            Dictionary<string, object> matches = new Dictionary<string, object>();
            foreach (KeyValuePair<string, object> child in all)
            {
                IDictionary<string, object> record = child.Value as IDictionary<string, object>;
                object fieldValue;
                if (record != null && record.TryGetValue(field, out fieldValue)
                    && string.Equals(Convert.ToString(fieldValue), value, StringComparison.Ordinal))
                {
                    matches[child.Key] = child.Value;
                }
            }
            return matches.Count == 0 ? null : Json.Serialize(matches);
        }

        /// <summary>Reads only the newest <paramref name="count"/> children of a
        /// node whose keys are Push keys (they sort by creation time). Ordering
        /// by key needs no .indexOn rule.</summary>
        public static string GetLast(string path, int count)
        {
            return Read(path, LastQuery(count));
        }

        internal static string WhereQuery(string field, string value)
        {
            return "orderBy=" + Uri.EscapeDataString("\"" + field + "\"")
                 + "&equalTo=" + Uri.EscapeDataString("\"" + value + "\"");
        }

        internal static string LastQuery(int count)
        {
            return "orderBy=" + Uri.EscapeDataString("\"$key\"") + "&limitToLast=" + count;
        }

        /// <summary>Replaces the node completely.</summary>
        public static string Put(string path, object value)
        {
            return Write("PUT", path, Json.Serialize(value));
        }

        /// <summary>Merges the given fields into the node, leaving the rest
        /// untouched. Prefer this over Put for partial updates so two people
        /// editing different fields do not overwrite each other.</summary>
        public static string Patch(string path, object value)
        {
            return Write("PATCH", path, Json.Serialize(value));
        }

        /// <summary>Appends a child under a generated key and returns that key.</summary>
        public static string Push(string path, object value)
        {
            string response = Write("POST", path, Json.Serialize(value));
            Dictionary<string, object> map = Json.ToMap(response);
            object name;
            return map.TryGetValue("name", out name) ? Convert.ToString(name) : null;
        }

        /// <summary>Creates a child under a new key in ONE request and stores the
        /// key inside the record as "Id" too. (Push followed by a Patch of the
        /// Id took two trips to Firebase.) Returns the key.</summary>
        public static string PushWithId(string path, object value)
        {
            string id = NewKey();
            System.Reflection.PropertyInfo idProperty = value == null ? null : value.GetType().GetProperty("Id");
            if (idProperty != null && idProperty.CanWrite && idProperty.PropertyType == typeof(string))
            {
                idProperty.SetValue(value, id, null);
                Put(path.TrimEnd('/') + "/" + id, value);
            }
            else
            {
                Dictionary<string, object> record = Json.ToMap(Json.Serialize(value));
                record["Id"] = id;
                Put(path.TrimEnd('/') + "/" + id, record);
            }
            return id;
        }

        // Push keys made here, exactly as the Firebase SDKs make them: 8 characters
        // of time (so keys still sort by creation time) and 12 random characters.
        private const string PushChars = "-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz";
        private static readonly object keyLock = new object();
        private static readonly System.Security.Cryptography.RandomNumberGenerator keyRandom =
            System.Security.Cryptography.RandomNumberGenerator.Create();
        private static long lastKeyTime;
        private static readonly int[] lastKeyRandom = new int[12];

        /// <summary>A new unique Firebase push key, made without a request.</summary>
        public static string NewKey()
        {
            lock (keyLock)
            {
                long now = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
                bool sameMillisecond = now == lastKeyTime;
                lastKeyTime = now;

                char[] key = new char[20];
                long time = now;
                for (int i = 7; i >= 0; i--)
                {
                    key[i] = PushChars[(int)(time % 64)];
                    time /= 64;
                }

                if (!sameMillisecond)
                {
                    byte[] bytes = new byte[12];
                    keyRandom.GetBytes(bytes);
                    for (int i = 0; i < 12; i++) lastKeyRandom[i] = bytes[i] % 64;
                }
                else
                {
                    // Same millisecond: add one to the last key so the order stays right.
                    int i = 11;
                    while (i >= 0 && lastKeyRandom[i] == 63) { lastKeyRandom[i] = 0; i--; }
                    if (i >= 0) lastKeyRandom[i]++;
                }
                for (int i = 0; i < 12; i++) key[8 + i] = PushChars[lastKeyRandom[i]];
                return new string(key);
            }
        }

        public static void Delete(string path)
        {
            Write("DELETE", path, null);
        }

        // Firebase rejects this write with 412 if another caller filled the node.
        public static bool PutIfEmpty(string path, object value)
        {
            return Write("PUT", path, Json.Serialize(value), onlyIfEmpty: true) != null;
        }

        // Read a version for compare-and-swap updates. Existing CRUD methods are unchanged.
        public static string GetWithEtag(string path, out string etag)
        {
            string version = null;
            string json = Send("GET", path, null, captureEtag: value => version = value);
            if (string.IsNullOrWhiteSpace(version))
                throw new InvalidOperationException("Could not verify the record version. Please refresh and try again.");
            etag = version;
            return json;
        }

        public static bool PutIfUnchanged(string path, object value, string etag)
        {
            if (string.IsNullOrWhiteSpace(etag)) throw new ArgumentException("A record version is required.", "etag");
            return Write("PUT", path, Json.Serialize(value), matchEtag: etag) != null;
        }

        // ------------------------------------------------------------------
        //  Read cache and parallel reads
        // ------------------------------------------------------------------

        private const string RequestCacheKey = "UIMS_FirebaseReads";
        private const string StatsKey = "UIMS_FirebaseStats";

        /// <summary>Goes up by one after every write. Cache keys include it,
        /// so every read cached before a write is never used again.</summary>
        private static long generation;

        private const string SharedPrefix = "UIMS_Firebase|";

        private static int cacheSeconds = -1;

        /// <summary>How long a read is reused by later requests of the same
        /// user. 0 turns that off (reads are then only reused inside one request).</summary>
        private static int CacheSeconds
        {
            get
            {
                if (cacheSeconds < 0)
                {
                    int seconds;
                    string value = WebConfigurationManager.AppSettings["Firebase.ReadCacheSeconds"];
                    cacheSeconds = int.TryParse(value, out seconds) ? Math.Max(0, seconds) : 30;
                }
                return cacheSeconds;
            }
        }

        private sealed class CachedRead
        {
            public string Json;
        }

        /// <summary>Changes data in Firebase, then empties the read cache.</summary>
        private static string Write(string method, string path, string body,
                                    bool onlyIfEmpty = false, string matchEtag = null)
        {
            try
            {
                return Send(method, path, body, null, onlyIfEmpty, false, matchEtag);
            }
            finally
            {
                // After the write, never before: a read that started before the
                // write landed must not be kept as the newest copy.
                Interlocked.Increment(ref generation);
            }
        }

        private static string CacheKey(long gen, string token, string path, string query)
        {
            return gen + "|" + (token ?? "anonymous") + "|" + path.Trim('/') + "?" + (query ?? "");
        }

        private static Dictionary<string, string> RequestCache(bool create)
        {
            HttpContext context = HttpContext.Current;
            if (context == null) return null;
            var cache = context.Items[RequestCacheKey] as Dictionary<string, string>;
            if (cache == null && create)
            {
                cache = new Dictionary<string, string>();
                context.Items[RequestCacheKey] = cache;
            }
            return cache;
        }

        private static bool TryGetCached(string key, out string json)
        {
            Dictionary<string, string> request = RequestCache(false);
            if (request != null && request.TryGetValue(key, out json)) return true;

            CachedRead shared = CacheSeconds > 0 ? HttpRuntime.Cache.Get(SharedPrefix + key) as CachedRead : null;
            if (shared != null)
            {
                json = shared.Json;
                request = RequestCache(true);
                if (request != null) request[key] = json;
                return true;
            }
            json = null;
            return false;
        }

        private static void StoreCached(string key, string json)
        {
            Dictionary<string, string> request = RequestCache(true);
            if (request != null) request[key] = json;
            if (CacheSeconds > 0)
            {
                HttpRuntime.Cache.Insert(SharedPrefix + key, new CachedRead { Json = json }, null,
                    DateTime.UtcNow.AddSeconds(CacheSeconds), System.Web.Caching.Cache.NoSlidingExpiration);
            }
        }

        private static void ForgetCached(string key)
        {
            Dictionary<string, string> request = RequestCache(false);
            if (request != null) request.Remove(key);
            HttpRuntime.Cache.Remove(SharedPrefix + key);
        }

        /// <summary>A GET answered from the cache when possible.</summary>
        private static string Read(string path, string query)
        {
            string key = CacheKey(Interlocked.Read(ref generation), CurrentToken(), path, query);
            string json;
            if (TryGetCached(key, out json))
            {
                CountCacheHit();
                return json;
            }
            json = Send("GET", path, null, query);
            StoreCached(key, json);
            return json;
        }

        /// <summary>Runs several reads at the same time and keeps the answers,
        /// so the repository calls that follow are answered at once. Reads
        /// already in the cache are skipped. Failures are ignored here: the
        /// normal repository call afterwards retries and reports them as usual.</summary>
        public static void Prefetch(params FirebaseRead[] reads)
        {
            Fetch(reads, false);
        }

        public static void Prefetch(IEnumerable<FirebaseRead> reads)
        {
            Fetch(reads, false);
        }

        /// <summary>Like Prefetch, but always asks Firebase, never the cache.
        /// Used by the sign-in check, which must see the account as it is now.</summary>
        public static void Reload(params FirebaseRead[] reads)
        {
            Fetch(reads, true);
        }

        private static void Fetch(IEnumerable<FirebaseRead> reads, bool fresh)
        {
            if (reads == null || !IsConfigured) return;

            long gen = Interlocked.Read(ref generation);
            string token = CurrentToken();
            var work = new Dictionary<string, string>();   // cache key -> url
            foreach (FirebaseRead read in reads)
            {
                if (read == null) continue;
                string key = CacheKey(gen, token, read.Path, read.Query);
                string ignored;
                if (work.ContainsKey(key) || (!fresh && TryGetCached(key, out ignored))) continue;
                work[key] = BuildUrl(read.Path, read.Query);
            }
            if (work.Count == 0) return;

            var results = new ConcurrentDictionary<string, string>();
            var failed = new ConcurrentBag<string>();
            Stopwatch watch = Stopwatch.StartNew();
            Parallel.ForEach(work, new ParallelOptions { MaxDegreeOfParallelism = 12 }, item =>
            {
                try { results[item.Key] = FetchUrl(item.Value); }
                catch (Exception) { failed.Add(item.Key); }
            });
            watch.Stop();
            CountCalls(work.Count, watch.ElapsedMilliseconds);

            foreach (KeyValuePair<string, string> result in results) StoreCached(result.Key, result.Value);
            // A failed fresh read must not leave an older copy to be used instead.
            if (fresh) foreach (string key in failed) ForgetCached(key);
        }

        /// <summary>Plain GET for the parallel reads. Those threads have no
        /// HttpContext, so there is no token refresh here.</summary>
        private static string FetchUrl(string url)
        {
            HttpWebRequest request = CreateRequest("GET", url);
            using (HttpWebResponse response = (HttpWebResponse)request.GetResponse())
            using (StreamReader reader = new StreamReader(response.GetResponseStream(), Encoding.UTF8))
            {
                string text = reader.ReadToEnd();
                return text == "null" ? null : text;
            }
        }

        private static HttpWebRequest CreateRequest(string method, string url)
        {
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);
            request.Method = method;
            request.ContentType = "application/json; charset=utf-8";
            request.Accept = "application/json";
            request.Timeout = 30000;
            request.KeepAlive = true;
            // Firebase compresses large collections, so they download much faster.
            request.AutomaticDecompression = DecompressionMethods.GZip | DecompressionMethods.Deflate;
            return request;
        }

        // ---- numbers for the Server-Timing header (browser dev tools) -----

        public sealed class RequestStats
        {
            public int Calls;
            public int CacheHits;
            public long Milliseconds;
        }

        /// <summary>Firebase calls made by the current request, or null.</summary>
        public static RequestStats Stats
        {
            get
            {
                HttpContext context = HttpContext.Current;
                return context == null ? null : context.Items[StatsKey] as RequestStats;
            }
        }

        private static RequestStats StatsForUpdate()
        {
            HttpContext context = HttpContext.Current;
            if (context == null) return null;
            var stats = context.Items[StatsKey] as RequestStats;
            if (stats == null) context.Items[StatsKey] = stats = new RequestStats();
            return stats;
        }

        private static void CountCalls(int calls, long milliseconds)
        {
            RequestStats stats = StatsForUpdate();
            if (stats == null) return;
            stats.Calls += calls;
            stats.Milliseconds += milliseconds;
        }

        private static void CountCacheHit()
        {
            RequestStats stats = StatsForUpdate();
            if (stats != null) stats.CacheHits++;
        }

        private static string Send(string method, string path, string body, string query = null,
                                   bool onlyIfEmpty = false, bool retried = false,
                                   string matchEtag = null, Action<string> captureEtag = null)
        {
            string url = BuildUrl(path, query);
            HttpWebRequest request = CreateRequest(method, url);
            Stopwatch watch = Stopwatch.StartNew();
            if (onlyIfEmpty) request.Headers["if-match"] = "null_etag";
            if (matchEtag != null) request.Headers["if-match"] = matchEtag;
            if (captureEtag != null) request.Headers["X-Firebase-ETag"] = "true";

            try
            {
                if (!string.IsNullOrEmpty(body))
                {
                    byte[] payload = Encoding.UTF8.GetBytes(body);
                    request.ContentLength = payload.Length;
                    using (Stream stream = request.GetRequestStream())
                    {
                        stream.Write(payload, 0, payload.Length);
                    }
                }
                using (HttpWebResponse response = (HttpWebResponse)request.GetResponse())
                using (StreamReader reader = new StreamReader(response.GetResponseStream(), Encoding.UTF8))
                {
                    if (captureEtag != null) captureEtag(response.Headers["ETag"]);
                    string text = reader.ReadToEnd();
                    return text == "null" ? null : text;
                }
            }
            catch (WebException ex)
            {
                HttpWebResponse response = ex.Response as HttpWebResponse;
                if ((onlyIfEmpty || matchEtag != null) && response != null && response.StatusCode == HttpStatusCode.PreconditionFailed)
                {
                    response.Dispose();
                    return null;
                }
                if (!retried && response != null &&
                    (response.StatusCode == HttpStatusCode.Unauthorized || response.StatusCode == HttpStatusCode.Forbidden))
                {
                    response.Dispose();
                    var session = HttpContext.Current == null ? null : HttpContext.Current.Session;
                    string refreshToken = session == null ? null : session[Common.Constants.SessionRefreshTokenKey] as string;
                    Services.AuthResult refreshed = Services.AuthService.RefreshIdToken(refreshToken);
                    if (!refreshed.Success || session == null) throw new FirebaseAuthExpiredException();
                    session[Common.Constants.SessionTokenKey] = refreshed.IdToken;
                    session[Common.Constants.SessionRefreshTokenKey] = refreshed.RefreshToken;
                    return Send(method, path, body, query, onlyIfEmpty, true, matchEtag, captureEtag);
                }
                throw new FirebaseException(method + " " + Scrub(url) + " failed: " + ReadError(ex), ex);
            }
            finally
            {
                CountCalls(1, watch.ElapsedMilliseconds);
            }
        }

        private static string ReadError(WebException ex)
        {
            if (ex.Response == null) return ex.Message;
            using (StreamReader reader = new StreamReader(ex.Response.GetResponseStream(), Encoding.UTF8))
            {
                string body = reader.ReadToEnd();
                return string.IsNullOrWhiteSpace(body) ? ex.Message : body;
            }
        }

        /// <summary>Keeps the auth token out of error messages and logs.</summary>
        private static string Scrub(string url)
        {
            int index = url.IndexOf("auth=", StringComparison.OrdinalIgnoreCase);
            return index < 0 ? url : url.Substring(0, index) + "auth=***";
        }
    }

    /// <summary>One read for FirebaseContext.Prefetch. Build it with the same
    /// path (and field) the repository uses, so its answer is found later.</summary>
    public sealed class FirebaseRead
    {
        public string Path { get; private set; }
        public string Query { get; private set; }

        /// <summary>A whole node, as FirebaseContext.Get(path) reads it.</summary>
        public static FirebaseRead Node(string path)
        {
            return string.IsNullOrEmpty(path) ? null : new FirebaseRead { Path = path };
        }

        /// <summary>The same read as FirebaseContext.GetWhere(path, field, value).</summary>
        public static FirebaseRead Where(string path, string field, string value)
        {
            if (string.IsNullOrEmpty(path) || string.IsNullOrEmpty(value)) return null;
            return new FirebaseRead { Path = path, Query = FirebaseContext.WhereQuery(field, value) };
        }

        /// <summary>The same read as FirebaseContext.GetLast(path, count).</summary>
        public static FirebaseRead Last(string path, int count)
        {
            if (string.IsNullOrEmpty(path)) return null;
            return new FirebaseRead { Path = path, Query = FirebaseContext.LastQuery(count) };
        }
    }

    public class FirebaseException : Exception
    {
        public FirebaseException(string message, Exception inner) : base(message, inner) { }
    }
}
