// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad  (Trello card X02)
//  JSON in and out of Firebase. Zero NuGet packages on purpose - see docs/04-git-workflow.md.
// =============================================================================

using System.Collections.Generic;
using System.Web.Script.Serialization;

namespace InternshipManagementSystem.Data
{
    /// <summary>
    /// The one place the whole system converts between objects and JSON.
    ///
    /// It uses JavaScriptSerializer, which ships inside .NET Framework
    /// (System.Web.Extensions), so a fresh clone builds and runs with no NuGet
    /// restore beyond the one package that was already here. With seven people
    /// on seven machines and three days left, that mattered more than the extra
    /// comfort of Newtonsoft.Json.
    ///
    /// If the team later wants Newtonsoft: install it and rewrite THIS FILE
    /// ONLY. Nothing else in the system touches a serializer.
    ///
    /// Note on dates: timestamps are long (Unix ms), never DateTime, because
    /// JavaScriptSerializer writes DateTime as "\/Date(123)\/" which is ugly
    /// inside Firebase and awkward to read from any other client. See
    /// Common/Time.cs.
    /// </summary>
    public static class Json
    {
        private static JavaScriptSerializer Create()
        {
            JavaScriptSerializer serializer = new JavaScriptSerializer();
            serializer.MaxJsonLength = int.MaxValue;
            serializer.RecursionLimit = 200;
            return serializer;
        }

        public static string Serialize(object value)
        {
            if (value == null) return "null";
            return Create().Serialize(value);
        }

        public static T Deserialize<T>(string json)
        {
            if (string.IsNullOrWhiteSpace(json) || json == "null") return default(T);
            return Create().Deserialize<T>(json);
        }

        /// <summary>For reading a node whose shape is not known in advance.</summary>
        public static Dictionary<string, object> ToMap(string json)
        {
            Dictionary<string, object> map = Deserialize<Dictionary<string, object>>(json);
            return map ?? new Dictionary<string, object>();
        }
    }
}
