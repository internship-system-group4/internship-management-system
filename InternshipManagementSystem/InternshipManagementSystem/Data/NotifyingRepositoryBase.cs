using System.Collections.Generic;
using InternshipManagementSystem.Services;

namespace InternshipManagementSystem.Data
{
    /// <summary>
    /// Repositories that notify people after a successful save.
    ///
    /// Each event gives the person exactly ONE notice in the bell:
    /// - if the repository overrides SendNotice, that sends the bilingual notice
    ///   (Services/NotificationService) and EmailNotificationService only sends the email;
    /// - otherwise EmailNotificationService writes its own inbox entry and the email.
    /// </summary>
    public abstract class NotifyingRepositoryBase<T> : RepositoryBase<T> where T : class
    {
        public override string Insert(T entity)
        {
            string id = base.Insert(entity);
            if (!string.IsNullOrEmpty(id)) NotifySaved(null, entity);
            return id;
        }

        public override void Save(string id, T entity)
        {
            T previous = null;
            bool captured = false;
            EmailNotificationService.TryNotify(() => { previous = GetById(id); captured = true; });
            base.Save(id, entity);
            if (captured) NotifySaved(previous, entity);
        }

        public override void Update(string id, Dictionary<string, object> changes)
        {
            if (string.IsNullOrEmpty(id) || changes == null || changes.Count == 0) return;
            T previous = null;
            EmailNotificationService.TryNotify(() => { previous = GetById(id); });
            base.Update(id, changes);
            if (previous != null)
                EmailNotificationService.TryNotify(() => NotifySaved(previous, GetById(id)));
        }

        /// <summary>Call after a save that did not go through Insert, Save or Update
        /// (for example a conditional write). <paramref name="previous"/> is null
        /// for a new record.</summary>
        protected void NotifySaved(T previous, T current)
        {
            bool sentOwnNotice = false;
            EmailNotificationService.TryNotify(() => { sentOwnNotice = SendNotice(previous, current); });
            EmailNotificationService.Saved(previous, current, !sentOwnNotice);
        }

        /// <summary>Override to send the bilingual bell notice for this change
        /// (previous is null for a new record). Return true when this change has
        /// its own notice, so the email service does not add a second one.</summary>
        protected virtual bool SendNotice(T previous, T current)
        {
            return false;
        }
    }
}
