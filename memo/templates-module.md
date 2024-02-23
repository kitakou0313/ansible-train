# template moduleのchanged判定について

## 検証したい内容
- 生成されるファイルの中身を変えず，パーミッションのみ切り替えた場合に`changed`と判定されるのか

## 実験結果
### ファイル作成
以下のplaybookを実行

```
---
- name: Place test file
  ansible.builtin.template:
    src: test.j2
    dest: /tmp/test.txt
    mode: '0666'

```

`test.j2`は以下
```
root@8b90b773d6a5:/workdir# cat roles/jinja/templates/test.j2 
test file
root@8b90b773d6a5:/workdir# 
```

```
root@8b90b773d6a5:/workdir# ansible-playbook -i hosts playbook.yaml 

PLAY [Ping all hosts] *********************************************************************************************

TASK [Gathering Facts] ********************************************************************************************
The authenticity of host 'node-1 (172.26.0.4)' can't be established.
ED25519 key fingerprint is SHA256:ln4POwv0PXh03ZyuLqZZ3UGMvU272xIhuQoyyLE9UN4.
This key is not known by any other names
The authenticity of host 'node-2 (172.26.0.3)' can't be established. 
ED25519 key fingerprint is SHA256:ln4POwv0PXh03ZyuLqZZ3UGMvU272xIhuQoyyLE9UN4.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
ok: [node-1]
yes
ok: [node-2]

TASK [ping : Ping all Managed nodes] ******************************************************************************
ok: [node-1]
ok: [node-2]

TASK [jinja : Place test file] ************************************************************************************
changed: [node-2]
changed: [node-1]

PLAY RECAP ********************************************************************************************************
node-1                     : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
node-2                     : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

root@8b90b773d6a5:/workdir# 
```

指定したパーミッションでファイルが作成されている
```
root@9c1f1942b1a8:~# ls -la /tmp/
total 12
drwxrwxrwt 1 root root 4096 Feb 23 13:57 .
drwxr-xr-x 1 root root 4096 Feb 23 13:55 ..
-rw-rw-rw- 1 root root   10 Feb 23 13:57 test.txt
root@9c1f1942b1a8:~# cat /tmp/test.txt 
test file
root@9c1f1942b1a8:~# 
```

playbookを変更せず実行すると，changedは0に
```
root@8b90b773d6a5:/workdir# ansible-playbook -i hosts playbook.yaml 

PLAY [Ping all hosts] *********************************************************************************************

TASK [Gathering Facts] ********************************************************************************************
ok: [node-1]
ok: [node-2]

TASK [ping : Ping all Managed nodes] ******************************************************************************
ok: [node-1]
ok: [node-2]

TASK [jinja : Place test file] ************************************************************************************
ok: [node-2]
ok: [node-1]

PLAY RECAP ********************************************************************************************************
node-1                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
node-2                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

root@8b90b773d6a5:/workdir# 
```

### playbookでパーミッション変更
moduleで設定するパーミッションを`644`に変更

```
---
- name: Place test file
  ansible.builtin.template:
    src: test.j2
    dest: /tmp/test.txt
    mode: '0644'

```

Playbookを実行 `changed`と判定されている
```
root@8b90b773d6a5:/workdir# ansible-playbook -i hosts playbook.yaml 

PLAY [Ping all hosts] *********************************************************************************************

TASK [Gathering Facts] ********************************************************************************************
ok: [node-2]
ok: [node-1]

TASK [ping : Ping all Managed nodes] ******************************************************************************
ok: [node-1]
ok: [node-2]

TASK [jinja : Place test file] ************************************************************************************
changed: [node-1]
changed: [node-2]

PLAY RECAP ********************************************************************************************************
node-1                     : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
node-2                     : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

root@8b90b773d6a5:/workdir# 
```

パーミッションも変化しているが，内容は変化していない　よってパーミッションの変化のみでも`changed`となる
```
root@9c1f1942b1a8:~# ls -la /tmp/
total 12
drwxrwxrwt 1 root root 4096 Feb 23 13:59 .
drwxr-xr-x 1 root root 4096 Feb 23 13:55 ..
-rw-r--r-- 1 root root   10 Feb 23 13:57 test.txt
root@9c1f1942b1a8:~# cat /tmp/test.txt 
test file
root@9c1f1942b1a8:~# 
```
