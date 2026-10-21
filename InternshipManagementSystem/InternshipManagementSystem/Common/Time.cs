// =============================================================================
//  University Internship Management System (UIMS)  -  Group 4
//  Unix-millisecond timestamps - the format Firebase itself uses.
//  Owner: Ahmad  (Trello card X02 - Shared Firebase Data Structure)
//  Do not edit without telling the owner: every page in the system depends on
//  these types. Add new fields, never rename or remove existing ones.
// =============================================================================

using System;

namespace InternshipManagementSystem.Common
{
    /// <summary>
    /// Every timestamp in this system is stored as Unix milliseconds (long),
    /// which is Firebase's own convention and survives JSON round-trips
    /// without timezone surprises. Models expose a [ScriptIgnore] DateTime
    /// companion property so pages can work with real dates.
    /// </summary>
    public static class Time
    {
        private static readonly DateTime Epoch =
            new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc);

        public static long NowMs()
        {
            return ToUnixMs(DateTime.UtcNow);
        }

        public static long ToUnixMs(DateTime value)
        {
            if (value == default(DateTime)) return 0;
            return (long)(value.ToUniversalTime() - Epoch).TotalMilliseconds;
        }

        public static DateTime FromUnixMs(long ms)
        {
            if (ms <= 0) return default(DateTime);
            return Epoch.AddMilliseconds(ms);
        }

        /// <summary>Local display string, or an em dash when there is no value.</summary>
        public static string Display(long ms)
        {
            if (ms <= 0) return "—";
            return FromUnixMs(ms).ToLocalTime().ToString("yyyy-MM-dd HH:mm");
        }

        public static string DisplayDate(long ms)
        {
            if (ms <= 0) return "—";
            return FromUnixMs(ms).ToLocalTime().ToString("yyyy-MM-dd");
        }

        public static bool IsPast(long ms)
        {
            return ms > 0 && ms < NowMs();
        }
    }
}
