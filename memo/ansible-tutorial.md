# Ansible

## 何？
- IaCを実現する構成管理ツールの一つ
- SSHでログインでき，PythonインタプリタがインストールされているサーバーであればまとめてPlaybookと呼ばれるファイルに記載されたコマンドを実行できる


## 構成要素
- Control node
    - Ansibleがインストールされたシステム
    - ユーザーはこのシステム上でAnsibleコマンドを実行する
- Managed Node
    - Ansibleが操作するシステム
    - SSHログインができ，pythonインタプリタがインストールされている必要がある
- Inventory
    - 論理的にまとめられたManeged Nodeの一覧
    - Control Node上に存在する


## Inventory
- yamlで記述する
- mnをGroupとして管理できる
- tips
    - Grouping時は以下の要素を意識するとよい
    - what
        - トポロジーによる分割
        - db, webなど
    - when
        - 開発プロセスにおけるステージ
        - dev, stage,prodなど
    - where
        - 地理的な橋よ
- Groupに階層構造を持たせることもできる
    - meta Group

## Playbook
- 自動化のBluePrint
- 実行されるPlayの順番が定義されている
    - play
        - taskの集合
        - 実行するMNにマップされている
    - Task
        - Moduleの集合
    - Module
        - 実行するコマンド，バイナリファイル
        - FQCNでMOdule毎にGroupingしている

### 実行結果の見方

```
PLAY [My First Play] ***************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************
ok: [mn2]
ok: [mn1]

TASK [Ping MN] *********************************************************************************************************************
ok: [mn1]
ok: [mn2]

TASK [Print Message] ***************************************************************************************************************
ok: [mn1] => {
    "msg": "Hello!"
}
ok: [mn2] => {
    "msg": "Hello!"
}

PLAY RECAP *************************************************************************************************************************
mn1                        : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
mn2                        : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```
- TASK [Gathering Facts] 
    - 暗黙的に実行されるTask
    - playbookで使用されるinventoryを検査
