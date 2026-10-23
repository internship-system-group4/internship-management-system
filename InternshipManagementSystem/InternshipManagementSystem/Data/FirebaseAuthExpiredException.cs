using System;
using InternshipManagementSystem.Common;

namespace InternshipManagementSystem.Data
{
    public class FirebaseAuthExpiredException : Exception
    {
        public FirebaseAuthExpiredException()
            : base(L.T("Workspace.FirebaseAuthExpiredException.YourSessionHasExpiredPleaseSign")) { }
    }
}
