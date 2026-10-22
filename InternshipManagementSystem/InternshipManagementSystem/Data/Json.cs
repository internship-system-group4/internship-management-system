// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad  (Trello card X02)
//  JSON in and out of Firebase. Zero NuGet packages on purpose - see docs/04-git-workflow.md.
// =============================================================================

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Reflection;
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

        /// <summary>Converts an already-parsed JSON value (a dictionary from
        /// Deserialize) into a typed object.</summary>
        public static T ConvertTo<T>(object value)
        {
            if (value == null) return default(T);
            IDictionary<string, object> map = value as IDictionary<string, object>;
            if (map != null) DropUnknownEnumValues(map, typeof(T));
            return Create().ConvertToType<T>(value);
        }

        /// <summary>A status typed by hand in the Firebase console (for example
        /// "Evaluated") is not a valid enum name and would make the whole read
        /// fail. Such fields are removed so they fall back to the default value,
        /// and a warning is logged so the bad data can be fixed.</summary>
        private static void DropUnknownEnumValues(IDictionary<string, object> map, Type type)
        {
            foreach (PropertyInfo property in type.GetProperties(BindingFlags.Public | BindingFlags.Instance))
            {
                Type enumType = Nullable.GetUnderlyingType(property.PropertyType) ?? property.PropertyType;
                if (!enumType.IsEnum) continue;

                string key = map.Keys.FirstOrDefault(k => string.Equals(k, property.Name, StringComparison.OrdinalIgnoreCase));
                if (key == null) continue;

                string text = map[key] as string;
                if (text == null || IsValidEnumText(enumType, text)) continue;

                Trace.TraceWarning("Ignored unknown {0} value '{1}' on {2}.{3}", enumType.Name, text, type.Name, property.Name);
                map.Remove(key);
            }
        }

        private static bool IsValidEnumText(Type enumType, string text)
        {
            long number;
            if (long.TryParse(text, out number)) return true;
            return Enum.GetNames(enumType).Any(n => string.Equals(n, text.Trim(), StringComparison.OrdinalIgnoreCase));
        }

        /// <summary>For reading a node whose shape is not known in advance.</summary>
        public static Dictionary<string, object> ToMap(string json)
        {
            Dictionary<string, object> map = Deserialize<Dictionary<string, object>>(json);
            return map ?? new Dictionary<string, object>();
        }
    }
}
