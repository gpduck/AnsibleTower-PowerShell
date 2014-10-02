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

    public class JsonParsers
    {
        public AnsibleTower.Organization ParseToOrganization(string JsonString)
        {
            AnsibleTower.Organization ConvertedObject = JsonConvert.DeserializeObject<AnsibleTower.Organization>(JsonString);
            return ConvertedObject;
        }
    }
}
