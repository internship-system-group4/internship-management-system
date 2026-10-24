using System.Collections.Generic;
using InternshipManagementSystem.Services;

namespace InternshipManagementSystem.Data
{
    /// <summary>Only opted-in repositories send email, and only after persistence succeeds.</summary>
    public abstract class NotifyingRepositoryBase<T> : RepositoryBase<T> where T : class
    {
        public override string Insert(T entity)
        {
            string id = base.Insert(entity);
            if (!string.IsNullOrEmpty(id)) EmailNotificationService.Saved(null, entity);
            return id;
        }

        public override void Save(string id, T entity)
        {
            T previous = null;
            bool captured = false;
            EmailNotificationService.TryNotify(() => { previous = GetById(id); captured = true; });
            base.Save(id, entity);
            if (captured) EmailNotificationService.Saved(previous, entity);
        }

        public override void Update(string id, Dictionary<string, object> changes)
        {
            if (string.IsNullOrEmpty(id) || changes == null || changes.Count == 0) return;
            T previous = null;
            EmailNotificationService.TryNotify(() => { previous = GetById(id); });
            base.Update(id, changes);
            if (previous != null)
                EmailNotificationService.TryNotify(() => EmailNotificationService.Saved(previous, GetById(id)));
        }
    }
}
