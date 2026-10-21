// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad  (Trello card A02)
//  Firebase Authentication over its REST API (cards A01-A05).
// =============================================================================

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
        public string Email { get; set; }

        /// <summary>Raw Firebase code, for example EMAIL_NOT_FOUND. Log this.</summary>
        public string ErrorCode { get; set; }

        /// <summary>Safe message for the UI. Never leaks whether an email
        /// exists, which is what card A03 means by "safe messages".</summary>
        public string ErrorMessage { get; set; }
    }

    /// <summary>
    /// Firebase Authentication through the Identity Toolkit REST endpoints.
    /// No SDK, no NuGet package - the REST API is a handful of HTTP posts and
    /// it works the same from a Web Forms code-behind as from anywhere else.
    ///
    /// One consequence worth knowing: CreateAccount signs up the new user and
    /// returns a token for THEM. That is harmless here because the coordinator's
    /// own sign-in lives in our Session, which this call never touches. Drop
    /// the returned token on the floor.
    /// </summary>
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
            return Call("signInWithPassword", body, "Incorrect email or password.");
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

        /// <summary>Card A03: send the password-reset email.</summary>
        public static AuthResult SendPasswordResetEmail(string email)
        {
            Dictionary<string, object> body = new Dictionary<string, object>
            {
                { "requestType", "PASSWORD_RESET" },
                { "email", email }
            };
            AuthResult result = Call("sendOobCode", body, "Could not send the reset email.");

            // Deliberately report success either way: telling the visitor that
            // an address is unknown hands an attacker a list of real accounts.
            result.Success = true;
            result.ErrorMessage = null;
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
            return Call("update", body, "Could not change the password.");
        }

        // ----------------------------------------------------------------
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
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);
            request.Method = "POST";
            request.ContentType = "application/json; charset=utf-8";
            request.Timeout = 30000;

            byte[] payload = Encoding.UTF8.GetBytes(Json.Serialize(body));
            request.ContentLength = payload.Length;
            using (Stream stream = request.GetRequestStream())
            {
                stream.Write(payload, 0, payload.Length);
            }

            try
            {
                using (HttpWebResponse response = (HttpWebResponse)request.GetResponse())
                using (StreamReader reader = new StreamReader(response.GetResponseStream(), Encoding.UTF8))
                {
                    Dictionary<string, object> map = Json.ToMap(reader.ReadToEnd());
                    result.Success = true;
                    result.Uid = Read(map, "localId");
                    result.IdToken = Read(map, "idToken");
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
            if (code.StartsWith("TOO_MANY_ATTEMPTS")) return "Too many attempts. Please try again later.";
            if (code.StartsWith("CREDENTIAL_TOO_OLD")) return "Please sign in again before changing your password.";
            return fallback;
        }
    }
}
