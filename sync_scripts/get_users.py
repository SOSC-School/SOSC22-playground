import requests
import pandas as pd
import os

api_url = 'https://jhub.example.com/hub/api'

token = os.environ.get("JHUB_TOKEN")


user_list = pd.read_csv("user_list.csv", sep="\t", header=None)

col = user_list.columns[0]

for user in user_list[col]:
    print(str(user))
    api_url = f'https://jhub.example.com/hub/authorize/{user[0]}'

    r = requests.post(api_url,
        headers={
            'Authorization': f'token {token}',
        },
        #verify=False,
        #params={'state': 'ready'}
    )



    api_url = f'https://jhub.example.com/hub/api/users/{user}'

    users_req = {
        "usernames": [user],
        "admin" : False if user not in ['admin'] else True
    }

    print(users_req)

    r = requests.post(api_url,
        headers={
            'Authorization': f'token {token}',

        },
        #verify=False,
        json = users_req
        #params={'state': 'ready'}
    )

    print(r.status_code)
    print(r.reason)

    api_url = f'https://jhub.example.com/hub/api/users/{user}/servers/'

    r = requests.post(api_url,
        headers={
            'Authorization': f'token {token}',

        },
        #verify=False,
        #params={'state': 'ready'}
    )

    print(r.status_code)
    print(r.reason)

import subprocess
import hashlib

users = list(user_list[col])

print(users)
for user in users:
    #if user not in ['dciangot']:
    hash_object = hashlib.md5(f'{user}'.encode())
    command = f"./sync_users.sh {user} {hash_object.hexdigest()}"
    
    res = subprocess.call(command, shell = True)

    print(f"Returned Value for {user}: {res}")
