using System;
using System.Collections;
using Newtonsoft.Json;
using System.Collections.Generic;

namespace AnsibleTower
{
    public class HashtableConverter : JsonConverter<Hashtable> {
        public override void WriteJson(JsonWriter writer, Hashtable hashtable, JsonSerializer serializer) {
            throw new NotImplementedException("Use defualt Hashtable serialization");
        }

        public override Hashtable ReadJson(JsonReader reader, Type objectType, Hashtable existingValue, bool hasExistingValue, JsonSerializer serializer) {
            Hashtable ht = new Hashtable();
            while(reader.Read()) {
                JsonToken readType = reader.TokenType;
                switch(reader.TokenType) {
                    case JsonToken.PropertyName:
                        String key = (string)reader.Value;
                        reader.Read();
                        if(reader.TokenType == JsonToken.StartObject) {
                            ht[key] = serializer.Deserialize<Hashtable>(reader);
                        } else if(reader.TokenType == JsonToken.StartArray) {
                            ht[key] = serializer.Deserialize<IList<object>>(reader);
                        } else if(reader.TokenType == JsonToken.String && String.IsNullOrEmpty(reader.Value.ToString())) {
                            return ht;
                        } else {
                            ht[key] = serializer.Deserialize(reader);
                        }
                        break;
                    default:
                        break;
                }
                if (readType == JsonToken.EndObject)
                {
                    break;
                }
            }
            return ht;
        }

        public override bool CanWrite { get { return false; }}
    }
}
