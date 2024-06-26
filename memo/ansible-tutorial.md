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
    - 各Playの先頭で暗黙的に実行されるTask
    - playbookで使用されるinventoryを検査
- PLAY RECAPの各ステータス
    - ok
        - 正常終了
    - changed
        - ホストに何か変化があったとき
            - ファイルの変更，Permissionの変更など
        - 冪等性の担保に良さそう



## Playbookの詳細
- Playの実行順
    - 上から順
    - ホストごとに並列でTaskを実行する
- Play内のTaskの実行順
    - 上から順
- variable
    - groupにもhost毎にも設定できる
    - 前者ならgroup内のホスト全てに，後者ならhost毎に適用される

## Playbookでできること
### templating
- [Templating ](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_templating.html#templating-jinja2)
- Jinja2を使用して動的な制御とデプロイ先の各種データの表示が可能
- ホストごとにIPアドレス，hostnameの表示などができる

### Filters
- 様々なデータの加工ができる
- 実行環境に注意
    - MN上では無くAnsible controller上で実行される

### Loop
- Moduleによってはlist内の変数をループできる
- yamlのハッシュを渡して参照することも可
    - Pythonの辞書では無いので文法に注意

### check mode
- `--check`引数で`--dry-run`に近いことができる
    - 実際にはManaged Nodeには変更を加えない
- Managed Nodeのvarsなどによる挙動の違いは確認できる

```
# ansible-playbook -i hosts playbook.yaml --check

PLAY [Ping all hosts] *********************************************************************************

TASK [Gathering Facts] ********************************************************************************
ok: [node-1]
ok: [node-2]

TASK [ping : Ping all Managed nodes] ******************************************************************
ok: [node-1]
ok: [node-2]

TASK [ping : Debug] ***********************************************************************************
ok: [node-1] => {
    "group_names": [
        "group1"
    ]
}
ok: [node-2] => {
    "group_names": [
        "group2"
    ]
}

TASK [jinja : Place test file] ************************************************************************
ok: [node-1]
ok: [node-2]

PLAY [Ping only group1 hosts] *************************************************************************

TASK [Gathering Facts] ********************************************************************************
ok: [node-1]
ok: [node-2]

TASK [ping : Ping all Managed nodes] ******************************************************************
skipping: [node-2]
ok: [node-1]

TASK [ping : Debug] ***********************************************************************************
ok: [node-1] => {
    "group_names": [
        "group1"
    ]
}
skipping: [node-2]

PLAY RECAP ********************************************************************************************
node-1                     : ok=7    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
node-2                     : ok=5    changed=0    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0   

```
