import requests
import json

# DSGCs: resources
# Datasets: libraries
# Signatures: signatures
# Genes: entities

def get_gene(name):
  API_URL = "https://ldp3.cloud/metadata-api/entities/find"
  
  payload = {
      "filter": {
          "where": {
              "meta": {
                  "fullTextSearch": name
              }
          },
          "limit": 2
      }
  }
  
  res = requests.post(API_URL, json=payload)
  results = res.json()
  return results[0]['id']

DATA_API = "https://ldp3.cloud/data-api/api/v1/"

g = get_gene("htr1a")
print(g)

query = {g,"limit":10,"database":"Overexpression"}

res = requests.post(DATA_API + "enrich/ranktwosided", json=query)
results = res.json()

# Optional, multiply z-down and direction-down with -1
for i in results["results"]:
    i["z-down"] = -i["z-down"]
    i["direction-down"] = -i["direction-down"]
print(json.dumps(results, indent=2))
