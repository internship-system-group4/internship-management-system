using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Text;
using InternshipManagementSystem.Data;

namespace InternshipManagementSystem.Services
{
    public class AuthResult
    {
        public bool Success { get; set; }
        public string Uid { get; set; }
        public string IdToken { get; set; }
        public string RefreshToken { get; set; }
        public long ExpiresIn { get; set; }
        public string Email { get; set; }

        /// <summary>Raw Firebase code, for example EMAIL_NOT_FOUND. Log this.</summary>
        public string ErrorCode { get; set; }

        /// <summary>Safe message for the UI. Never leaks whether an email
        /// exists, which is what card A03 means by "safe messages".</summary>
        public string ErrorMessage { get; set; }
    }

    // Firebase Authentication REST endpoints. Account creation does not change the session.
    public static class AuthService
    {
        private const string Base = "https://identitytoolkit.googleapis.com/v1/accounts:";

        /// <summary>Card A02: verify an email and password.</summary>
        public static AuthResult SignIn(string email, string password)
        {
            Dictionary<string, object> body = new Dictionary<string, object>
            {
                { "email", email },
                { "password", password },
                { "returnSecureToken", true }
            };
            AuthResult result = Call("signInWithPassword", body, "Incorrect email or password.");
            // The profile lookup immediately after sign-in also needs authentication.
            StoreTokens(result);
            return result;
        }

        /// <summary>Cards A05, A07, N03: the coordinator creates an account with
        /// a temporary password. Store the returned Uid as the users/{uid} key
        /// and set MustChangePassword = true on the profile.</summary>
        public static AuthResult CreateAccount(string email, string temporaryPassword)
        {
            Dictionary<string, object> body = new Dictionary<string, object>
            {
                { "email", email },
                { "password", temporaryPassword },
                { "returnSecureToken", true }
            };
            return Call("signUp", body, "Could not create the account.");
        }

        /// <summary>Card A05: deletes an account that was just created, using
        /// the IdToken returned by CreateAccount. Used when the database record
        /// could not be saved, so the email can be used again.</summary>
        public static AuthResult DeleteAccount(string idToken)
        {
            Dictionary<string, object> body = new Dictionary<string, object>
            {
                { "idToken", idToken }
            };
            return Call("delete", body, "Could not delete the account.");
        }

        /// <summary>Card A03: send the password-reset email.</summary>
        public static AuthResult SendPasswordResetEmail(string email)
        {
            Dictionary<string, object> body = new Dictionary<string, object>
            {
                { "requestType", "PASSWORD_RESET" },
                { "email", email }
            };
            AuthResult result = Call("sendOobCode", body, "Could not send the reset email. Please try again later.");

            // Report success for unknown or disabled accounts too: telling the
            // visitor that an address is unknown hands an attacker a list of
            // real accounts. Other errors (no internet, too many requests,
            // Firebase not configured) are still shown.
            if (result.ErrorCode != null
                && (result.ErrorCode.StartsWith("EMAIL_NOT_FOUND") || result.ErrorCode.StartsWith("USER_DISABLED")))
            {
                result.Success = true;
                result.ErrorMessage = null;
            }
            return result;
        }

        /// <summary>Card A04: change the password of the signed-in user.
        /// Pass the IdToken kept in session at sign-in.</summary>
        public static AuthResult ChangePassword(string idToken, string newPassword)
        {
            Dictionary<string, object> body = new Dictionary<string, object>
            {
                { "idToken", idToken },
                { "password", newPassword },
                { "returnSecureToken", true }
            };
            AuthResult result = Call("update", body, "Could not change the password.");
            StoreTokens(result);
            return result;
        }

        public static AuthResult RefreshIdToken(string refreshToken)
        {
            if (string.IsNullOrEmpty(refreshToken) || string.IsNullOrEmpty(FirebaseContext.ApiKey))
                return new AuthResult { ErrorMessage = "Please sign in again." };

            string url = "https://securetoken.googleapis.com/v1/token?key=" + Uri.EscapeDataString(FirebaseContext.ApiKey);
            string body = "grant_type=refresh_token&refresh_token=" + Uri.EscapeDataString(refreshToken);
            return Post(url, body, "application/x-www-form-urlencoded", "Please sign in again.", true);
        }

        private static void StoreTokens(AuthResult result)
        {
            var context = System.Web.HttpContext.Current;
            if (!result.Success || context == null || context.Session == null) return;
            context.Session[Common.Constants.SessionTokenKey] = result.IdToken;
            context.Session[Common.Constants.SessionRefreshTokenKey] = result.RefreshToken;
        }

        private static AuthResult Call(string method, Dictionary<string, object> body, string friendlyError)
        {
            AuthResult result = new AuthResult();

            string apiKey = FirebaseContext.ApiKey;
            if (string.IsNullOrEmpty(apiKey))
            {
                result.ErrorCode = "NOT_CONFIGURED";
                result.ErrorMessage = "Firebase is not configured yet. See docs/05-firebase-setup.md.";
                return result;
            }

            string url = Base + method + "?key=" + Uri.EscapeDataString(apiKey);
            return Post(url, Json.Serialize(body), "application/json; charset=utf-8", friendlyError, false);
        }

        private static AuthResult Post(string url, string body, string contentType, string friendlyError, bool refresh)
        {
            AuthResult result = new AuthResult();
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);
            request.Method = "POST";
            request.ContentType = contentType;
            request.Timeout = 30000;

            try
            {
                byte[] payload = Encoding.UTF8.GetBytes(body);
                request.ContentLength = payload.Length;
                using (Stream stream = request.GetRequestStream())
                {
                    stream.Write(payload, 0, payload.Length);
                }

                using (HttpWebResponse response = (HttpWebResponse)request.GetResponse())
                using (StreamReader reader = new StreamReader(response.GetResponseStream(), Encoding.UTF8))
                {
                    Dictionary<string, object> map = Json.ToMap(reader.ReadToEnd());
                    result.Success = true;
                    result.Uid = Read(map, "localId");
                    result.IdToken = Read(map, refresh ? "id_token" : "idToken");
                    result.RefreshToken = Read(map, refresh ? "refresh_token" : "refreshToken");
                    long expiresIn;
                    long.TryParse(Read(map, refresh ? "expires_in" : "expiresIn"), out expiresIn);
                    result.ExpiresIn = expiresIn;
                    if (refresh && (string.IsNullOrEmpty(result.IdToken) || string.IsNullOrEmpty(result.RefreshToken)))
                    {
                        result.Success = false;
                        result.ErrorMessage = friendlyError;
                    }
                    result.Email = Read(map, "email");
                    return result;
                }
            }
            catch (WebException ex)
            {
                result.Success = false;
                result.ErrorCode = ReadErrorCode(ex);
                result.ErrorMessage = Friendly(result.ErrorCode, friendlyError);
                return result;
            }
            catch (Exception ex) when (refresh &&
                (ex is ArgumentException || ex is InvalidOperationException || ex is IOException))
            {
                return new AuthResult { ErrorCode = "INVALID_REFRESH_RESPONSE", ErrorMessage = friendlyError };
            }
        }

        private static string Read(Dictionary<string, object> map, string key)
        {
            object value;
            return map.TryGetValue(key, out value) ? Convert.ToString(value) : null;
        }

        private static string ReadErrorCode(WebException ex)
        {
            if (ex.Response == null) return "NETWORK_ERROR";
            try
            {
                using (StreamReader reader = new StreamReader(ex.Response.GetResponseStream(), Encoding.UTF8))
                {
                    Dictionary<string, object> map = Json.ToMap(reader.ReadToEnd());
                    object error;
                    if (map.TryGetValue("error", out error))
                    {
                        Dictionary<string, object> detail = error as Dictionary<string, object>;
                        if (detail != null) return Read(detail, "message");
                    }
                }
            }
            catch
            {
                // fall through to the generic code
            }
            return "UNKNOWN_ERROR";
        }

        /// <summary>Maps Firebase codes to messages a user can act on, without
        /// revealing which half of the credentials was wrong.</summary>
        private static string Friendly(string code, string fallback)
        {
            if (string.IsNullOrEmpty(code)) return fallback;
            if (code.StartsWith("EMAIL_EXISTS")) return "An account with this email already exists.";
            if (code.StartsWith("WEAK_PASSWORD")) return "The password must be at least 6 characters.";
            if (code.StartsWith("INVALID_EMAIL")) return "That email address is not valid.";
            if (code.StartsWith("EMAIL_NOT_FOUND")
                || code.StartsWith("INVALID_PASSWORD")
                || code.StartsWith("INVALID_LOGIN_CREDENTIALS")) return "Incorrect email or password.";
            if (code.StartsWith("USER_DISABLED")) return "This account has been deactivated.";
            if (code.StartsWith("TOO_MANY_ATTEMPTS")
                || code.StartsWith("RESET_PASSWORD_EXCEED_LIMIT")) return "Too many attempts. Please try again later.";
            if (code.StartsWith("CREDENTIAL_TOO_OLD")) return "Please sign in again before changing your password.";
            return fallback;
        }
    }
}
