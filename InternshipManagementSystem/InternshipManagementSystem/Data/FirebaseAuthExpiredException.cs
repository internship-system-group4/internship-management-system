using System;

namespace InternshipManagementSystem.Data
{
    public class FirebaseAuthExpiredException : Exception
    {
        public FirebaseAuthExpiredException()
            : base("Your session has expired. Please sign in again.") { }
    }
}
