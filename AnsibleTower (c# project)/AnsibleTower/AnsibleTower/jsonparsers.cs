using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;

namespace AnsibleTower
{
    public class JsonParsers
    {
        public AnsibleTower.Organization ParseToOrganization(string JsonString)
        {
            AnsibleTower.Organization ConvertedObject = JsonConvert.DeserializeObject<AnsibleTower.Organization>(JsonString);
                return ConvertedObject;
        }
    }
}
