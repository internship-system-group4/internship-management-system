// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad  (Trello card X02)
//  Generic CRUD so nobody writes raw Firebase paths in a page.
// =============================================================================

using System;
using System.Collections.Generic;
using System.Diagnostics;

namespace InternshipManagementSystem.Data
{
    /// <summary>
    /// Base class for every repository. A page should never call
    /// FirebaseContext directly - go through a repository so the path, the key
    /// handling and the id assignment stay in one place.
    ///
    /// Each entity is stored as  {collection}/{id}  and the id is also kept
    /// inside the object, so a record read back from Firebase already knows
    /// its own key.
    /// </summary>
    public abstract class RepositoryBase<T> where T : class
    {
        protected abstract string Collection { get; }

        /// <summary>Set the Id property on an instance. Implemented per entity
        /// because the base class cannot know the property.</summary>
        protected abstract void SetId(T entity, string id);

        public virtual T GetById(string id)
        {
            if (string.IsNullOrEmpty(id)) return null;
            T entity = Json.ConvertTo<T>(Json.Deserialize<object>(FirebaseContext.Get(Collection + "/" + id)));
            if (entity != null) SetId(entity, id);
            return entity;
        }

        public virtual List<T> GetAll()
        {
            return Materialise(FirebaseContext.Get(Collection));
        }

        /// <summary>Server-side filter. Needs an .indexOn rule for the field.</summary>
        public virtual List<T> GetWhere(string field, string value)
        {
            if (string.IsNullOrEmpty(value)) return new List<T>();
            return Materialise(FirebaseContext.GetWhere(Collection, field, value));
        }

        /// <summary>Creates the record under a generated key and returns the
        /// id, which is also written onto the entity.</summary>
        public virtual string Insert(T entity)
        {
            // One request: the key is made here and stored inside the record too,
            // so reads from anywhere (including the Firebase console) carry the id.
            string id = FirebaseContext.PushWithId(Collection, entity);
            SetId(entity, id);
            return id;
        }

        /// <summary>Creates or replaces the record at a known id - used when
        /// the key must be the Firebase Auth UID (see UserRepository).</summary>
        public virtual void Save(string id, T entity)
        {
            SetId(entity, id);
            FirebaseContext.Put(Collection + "/" + id, entity);
        }

        /// <summary>Merges changed fields only. Safer than Save when two roles
        /// can touch different parts of the same record.</summary>
        public virtual void Update(string id, Dictionary<string, object> changes)
        {
            if (string.IsNullOrEmpty(id) || changes == null || changes.Count == 0) return;
            FirebaseContext.Patch(Collection + "/" + id, changes);
        }

        public virtual void Delete(string id)
        {
            if (string.IsNullOrEmpty(id)) return;
            FirebaseContext.Delete(Collection + "/" + id);
        }

        // ----------------------------------------------------------------
        /// <summary>Firebase returns an object keyed by id, not an array.
        /// This turns it into a list with the ids filled in.</summary>
        protected List<T> Materialise(string json)
        {
            List<T> results = new List<T>();
            if (string.IsNullOrWhiteSpace(json) || json == "null") return results;

            // Read the raw records first, then convert each one on its own, so a
            // single bad record (for example a status value typed by hand in the
            // Firebase console) is skipped instead of crashing the whole page.
            Dictionary<string, object> map = Json.Deserialize<Dictionary<string, object>>(json);
            if (map == null) return results;

            foreach (KeyValuePair<string, object> pair in map)
            {
                if (pair.Value == null) continue;
                T entity;
                try
                {
                    entity = Json.ConvertTo<T>(pair.Value);
                }
                catch (Exception ex)
                {
                    Trace.TraceWarning("Skipped unreadable record {0}/{1}: {2}", Collection, pair.Key, ex.Message);
                    continue;
                }
                if (entity == null) continue;
                SetId(entity, pair.Key);
                results.Add(entity);
            }
            return results;
        }
    }
}
