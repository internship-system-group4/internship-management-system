using System;
using System.Collections.Generic;
using System.IO;
using System.Web.Hosting;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Data
{
    public class CompletionRuleRepository
    {
        public List<CompletionRule> GetAll()
        {
            string path = HostingEnvironment.MapPath("~/App_Data/completion-rules.json");
            if (path == null || !File.Exists(path)) return new List<CompletionRule>();
            try { return Json.Deserialize<List<CompletionRule>>(File.ReadAllText(path)) ?? new List<CompletionRule>(); }
            catch (ArgumentException) { return new List<CompletionRule>(); }
        }
    }
}
