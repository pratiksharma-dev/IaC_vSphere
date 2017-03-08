using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
namespace JsonDeserializer
{
    public static class Jsontool
    {
        
        public static JsonDerializer.JsonDerialize Deseerializer(string json)
        {
            return JsonConvert.DeserializeObject<JsonDerializer.JsonDerialize>(json);
        }
    }
}
