using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;


namespace AnsibleTower
{
    public class Organization
    {
        public int id { get; set; }
        public string type { get; set; }
        public string url { get; set; }
        //public Related related { get; set; }
        //public SummaryFields summary_fields { get; set; }
        public string created { get; set; }
        public string modified { get; set; }
        public string name { get; set; }
        public string description { get; set; }
    }

    public class User
    {

    public int id { get; set; }
    public string type { get; set; }
    public string url { get; set; }
    public string created { get; set; }
    public string username { get; set; }
    public string first_name { get; set; }
    public string last_name { get; set; }
    public string email { get; set; }
    public bool is_superuser { get; set; }
    public string ldap_dn { get; set; }

    }

    public class Project
    {
        public int id { get; set; }
        public string type { get; set; }
        public string url { get; set; }
        public DateTime created { get; set; }
        public DateTime modified { get; set; }
        public string name { get; set; }
        public string description { get; set; }
        public string local_path { get; set; }
        public string scm_type { get; set; }
        public string scm_url { get; set; }
        public string scm_branch { get; set; }
        public bool scm_clean { get; set; }
        public bool scm_delete_on_update { get; set; }
        public object credential { get; set; }
        public DateTime last_job_run { get; set; }
        public bool last_job_failed { get; set; }
        public bool has_schedules { get; set; }
        public object next_job_run { get; set; }
        public string status { get; set; }
        public bool scm_delete_on_next_update { get; set; }
        public bool scm_update_on_launch { get; set; }
        public int scm_update_cache_timeout { get; set; }
        public bool last_update_failed { get; set; }
        public string last_updated { get; set; }
    }



    public class JsonFunctions
    {
        public AnsibleTower.Organization ParseToOrganization(string JsonString)
        {
            AnsibleTower.Organization ConvertedObject = JsonConvert.DeserializeObject<AnsibleTower.Organization>(JsonString);
            return ConvertedObject;
        }

        public AnsibleTower.User ParseToUser(string JsonString)
        {
            AnsibleTower.User ConvertedObject = JsonConvert.DeserializeObject<AnsibleTower.User>(JsonString);
            return ConvertedObject;
        }
    
    }


}
