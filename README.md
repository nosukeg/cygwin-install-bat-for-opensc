<div style="text-align: right;">
cygwin install bat for opensc 2022-09-15
</div>

# OpenSC を Cygwin に導入する

## やりたい事
マイナンバーカードの内容や仕組みに触れてみたい。

## 背景
ssh の公開鍵認証にマイナンバーカードが使えるのか興味を持った事が始まりです。

## 導入手順
OpenSC を make する為に、Cygwin の新規インストールが推奨されています。また、そこに十数個の追加パッケージが必要です。以下は、既存 Cygwin インストールを残したまま、そこに OpenSC を導入することを目的とした手順です。
- 既存 Cygwin インストールと別に、新規に Cygwin をインストールします。
- 新規 Cygwin インストール上で、OpenSC を /usr/local/OpenSC にインストールします。
- 新規 Cygwin インストール上の /usr/local/OpenSC を既存 Cygwin インストールへ移し、利用します。

### 新規 Cygwin のインストール
この手間を軽減するために、バッチファイル（**CygInst4OpenSC.bat**）を作りました。以下、参考 URL です。
- [OpenSC/Wiki の Developer Documentation - Compiling on Cygwin](https://github.com/OpenSC/OpenSC/wiki/Compiling-on-Cygwin)
- [Cygwin/FAQ の Does the Cygwin Setup program accept command-line arguments?](https://www.cygwin.com/faq.html#faq.setup.cli)

バッチファイルの内容は次の通りです。
| 行    | 内容                                               |
|:-----:| :--------------------------------------------------|
| 1-3   | 定番(?)のおまじない                                   |
| 5-9   | 環境変数を設定                                     |
| 11-21 | Root Install 及び Local Package ディレクトリの作成 |
| 24    | setup-x86_64.exe の実行                            |
| 26-34 | 注意書きを表示                                     |
| 36    | 上の注意書きを留めるための一時停止                 |

環境変数のそれぞれの意味は次の通りで、**CygSite を指定します**。
| 環境変数       | 意味                                                                       | 備考                                   |
|:---------------|:---------------------------------------------------------------------------|:---------------------------------------|
| CygRoot        | GUI インストール時の Select Root Install Directory で指定するディレクトリ  | 作業後、削除可能です                   |
| CygPackage     | GUI インストール時の Select Local Package Directory で指定するディレクトリ | 作業後、削除可能です                   |
| **CygSite**    | GUI インストール時の Choose A Download Site で指定するサイト     　　　　  | **普段使いのサイトを指定します** |
| InstallPackage | [こちら](https://github.com/OpenSC/OpenSC/wiki/Compiling-on-Cygwin)の Install additional Cygwin packages に示されているパッケージ | お好みのものがあれば、ここに追加します。例: vim |

### make と既存 Cygwin インストールへの設置手順
- デスクトップ等に一時的に作成したフォルダに、上のバッチファイルと https://www.cygwin.com/ からダウンロードした setup-x86_64.exe 置き、**CygSite を指定後**、バッチファイルを実行します。
- "インストールしようとしているアプリは、Microsoft 検証済みアプリではありません" と表示されます。インストールする で進みます。
- "この不明な発行元からのアプリがデバイスに変更を加えることを許可しますか？" と表示されます。はい で進みます。
- Cygwin Setup 画面が表示され、インストールが進みます。
- インストールが終わると、Cygwin Setup 画面が自動的に閉じます。

    ※ このバッチファイル実行後、既存 Cygwin インストールを GUI でアップデート等する際に、Root Install および Local Package ディレクトリが変わっています。GUI 操作の過程で元に戻すことに注意します。
- OpenSC を新規 Cygwin インストール上で make する為に、%CygRoot%\bin\mintty.exe のショートカットを適当な所（デスクトップ等）へ作り、そのプロパティ の リンク先 に オプション " -i /Cygwin-Terminal.ico -" を追加・適用し起動します。
- mintty 起動後、画面の右クリック Options で Text の ロケール と キャラクターセット や その他の項目 を、お好みに調整します。
- ./configure に prefix を追加する以外は、[こちら](https://github.com/OpenSC/OpenSC/wiki/Compiling-on-Cygwin)の Build OpenSC に従い進めます。prefix を指定したのは、make; make install 後、/usr/local/OpenSC を tar でまとめ、既存 Cygwin インストールへ持っていく為です。お好みで変更します。
~~~
$ ./configure --disable-strict --prefix=/usr/local/OpenSC
~~~
- make install 後、/usr/local/OpenSC を tar でまとめます。
~~~
$ tar zcf /tmp/OpenSC.tgz -C /usr/local OpenSC
~~~
- /tmp/OpenSC.tgz を 既存 Cygwin インストールの /usr/local/ へ移し展開します。また、/usr/local/OpenSC/bin へ PATH を通し、/usr/local/OpenSC/etc/bash_completion.d/ がありますので、お好みで、.bashrc などで取り込むように設定します。
- デスクトップ等に一時的に作成したフォルダは、不要になったら削除します。

# マイナンバーカードを OpenSC で試してみる

## opensc-tool コマンド
### OpenSC のバージョンを確認する
~~~
$ opensc-tool --version
OpenSC-0.22.0-rc1-720-gfa2eab86, rev: fa2eab86, commit-time: 2022-09-12 10:30:13 +0200
~~~
### PC に接続しているカードリーダーを一覧する
~~~
$ opensc-tool --list-readers
# Detected readers (pcsc)
Nr.  Card  Features  Name
0    Yes             Sony FeliCa Port/PaSoRi 3.0 0
~~~
### カードリーダーにセットされているカードの識別とその名前を表示する
~~~
$ opensc-tool --name
Using reader with a card: Sony FeliCa Port/PaSoRi 3.0 0
jpki
~~~
### OpenSC に内蔵されているカード ドライバを一覧する
jpki カードドライバが組み込まれた経緯は、[こちら](https://github.com/OpenSC/OpenSC/pull/801)にあります。hamano 氏の仕事に敬意を表します。
~~~
$ opensc-tool --list-drivers
Available card drivers:
  ～～～
  openpgp          OpenPGP card
  jpki             JPKI(Japanese Individual Number Cards)
  npa              German ID card (neuer Personalausweis, nPA)
  ～～～
~~~
## pkcs15-tool コマンド
### PIN を一覧する
ユーザ認証用、電子署名用 が、それぞれ表示されます（合計 2 つ）。表示内容に、PIN の残り試行回数が表示されます。
~~~
$ pkcs15-tool --list-pins
~~~
### 秘密鍵を一覧する
ユーザ認証用、電子署名用 が、それぞれ表示されます（合計 2 つ）。
~~~
$ pkcs15-tool --list-keys
~~~
### 公開鍵を一覧する
ユーザ認証用、電子署名用 が、それぞれ表示されます（合計 2 つ）。
~~~
$ pkcs15-tool --list-public-keys
~~~
### 電子証明書を一覧する
※ これ以降の電子証明書の分類（自治体、JPKI）は便宜的に用いています。

自治体、JPKI、それぞれが発行元の ユーザ認証用、電子署名用 のものが表示されます（合計 4 つ）。
~~~
$ pkcs15-tool --list-certificates
~~~
### カード上の全てのオブジェクトを一覧する
※ これ以降、ID 1、3：ユーザ認証用。ID 2、4：電子署名用 です。

カード オブジェクトに加え、上で表示した PIN から電子証明書までが一覧されます（総合計 11 個）。下表は ID と表示内容の対応です。
~~~
$ pkcs15-tool --dump
~~~
| ID | PIN | 秘密鍵 | 公開鍵 | 電子証明書/自治体 | 電子証明書/JPKI |
|:--:|:---:|:------:|:------:|:-----------------:|:---------------:|
| 1  | 〇  | 〇     | 〇     | 〇                | ー              |
| 2  | 〇  | 〇     | 〇     | 〇                | ー              |
| 3  | ー  | ー     | ー     | ー                | 〇              |
| 4  | ー  | ー     | ー     | ー                | 〇              |

### 電子証明書/JPKI から公開鍵を読み出す
※ [参考: 電子証明書/JPKI から公開鍵を読み出す について（pkcs15-tool）](https://github.com/nosukeg/cygwin-install-bat-for-opensc#%E9%9B%BB%E5%AD%90%E8%A8%BC%E6%98%8E%E6%9B%B8jpki-%E3%81%8B%E3%82%89%E5%85%AC%E9%96%8B%E9%8D%B5%E3%82%92%E8%AA%AD%E3%81%BF%E5%87%BA%E3%81%99-%E3%81%AB%E3%81%A4%E3%81%84%E3%81%A6pkcs15-tool)
~~~
$ pkcs15-tool --read-public-key 3
$ pkcs15-tool --read-public-key 4
~~~
### 電子証明書/JPKI から公開鍵を読み出す（ssh フォーマット）
~~~
$ pkcs15-tool --read-ssh-key 3
$ pkcs15-tool --read-ssh-key 4
~~~
### 電子証明書/JPKI から公開鍵を読み出す（RFC 4716 フォーマット）
~~~
$ pkcs15-tool --read-ssh-key 3 --rfc4716
$ pkcs15-tool --read-ssh-key 4 --rfc4716
~~~
## pkcs11-tool コマンド
### スロットを一覧する
~~~
$ pkcs11-tool --list-slots
Available slots:
Slot 0 (0x0): Sony FeliCa Port/PaSoRi 3.0 0
  token label        : JPKI (User Authentication PIN)
  token manufacturer : JPKI
  token model        : PKCS#15 emulated
  token flags        : login required, token initialized, PIN initialized
  ～～～
Slot 1 (0x1): Sony FeliCa Port/PaSoRi 3.0 0
  token label        : JPKI (Digital Signature PIN)
  token manufacturer : JPKI
  token model        : PKCS#15 emulated
  token flags        : login required, token initialized, PIN initialized
  ～～～
~~~
### カードへのアクセスを試す
~~~
$ pkcs11-tool --test
$ pkcs11-tool --slot 1 --test
~~~
### global token の情報を表示する
~~~
$ pkcs11-tool --show-info
$ pkcs11-tool --slot 1 --show-info
~~~
### PKCS #11 3.0 ライブラリの interface を表示する
~~~
$ pkcs11-tool --list-interfaces
$ pkcs11-tool --slot 1 --list-interfaces
~~~
### トークンで利用できる方式を一覧する
~~~
$ pkcs11-tool --list-mechanisms
$ pkcs11-tool --slot 1 --list-mechanisms
~~~
### オブジェクトを一覧する
下表は Slot/ID の組と表示内容の対応です。
~~~
$ pkcs11-tool --login --list-objects
$ pkcs11-tool --slot 1 --login --list-objects
~~~

| Slot/ID | 秘密鍵 | 公開鍵 | 電子証明書/自治体 | 電子証明書/JPKI | 公開鍵/JPKI |
|:-------:|:------:|:------:|:-----------------:|:---------------:|:-----------:|
| 0/1     | 〇     | 〇     | 〇                | ー              | ー          |
| 1/2     | 〇     | 〇     | 〇                | ー              | ー          |
| 0/3     | ー     | ー     | ー                | 〇              | 〇          |
| 0/4     | ー     | ー     | ー                | 〇              | 〇          |

## 暗号操作をする（openssl コマンドを併用）
**次の表は各鍵の Usage 及び Access Flags を整理しています。**
#### pkcs15-tool で見た場合
| ID | 種類   | Usage                         | Access Flags                                            |
|:--:|:------:|:------------------------------|:--------------------------------------------------------|
| 1  | 秘密鍵 | [0x04], sign                  | [0x1D], sensitive, alwaysSensitive, neverExtract, local |
| 1  | 公開鍵 | [0x00]                        | [0x02], extract                                         |
| 2  | 秘密鍵 | [0x204], sign, nonRepudiation | [0x1D], sensitive, alwaysSensitive, neverExtract, local |
| 2  | 公開鍵 | [0x00]                        | [0x02], extract                                         |

#### pkcs11-tool で見た場合
| ID | 種類   | Usage                 | Access Flags                                                               |
|:--:|:------:|:----------------------|:---------------------------------------------------------------------------|
| 1  | 秘密鍵 | sign                  | sensitive, always sensitive, never extractable, local                      |
| 1  | 公開鍵 | none                  | none                                                                       |
| 2  | 秘密鍵 | sign, non-repudiation | always authenticate, sensitive, always sensitive, never extractable, local |
| 2  | 公開鍵 | none                  | none                                                                       |
| 3  | 公開鍵 | encrypt, verify       | local                                                                      |
| 4  | 公開鍵 | encrypt, verify       | local                                                                      |

### 電子証明書や公開鍵を取り出す
**次は、ID 1、3、4 に適用できます。**
~~~
$ pkcs15-tool --read-certificate 1 --output id1_cert.pem
$ openssl x509 -in id1_cert.pem -pubkey -noout -out id1_pub.pem
~~~
又は
~~~
$ pkcs11-tool --read-object --id 1 --type cert --output-file id1_cert.der
$ openssl x509 -in id1_cert.der -inform DER -pubkey -noout -out id1_pub.pem
~~~
もしくは
~~~
$ pkcs11-tool --read-object --id 1 --type pubkey --output-file id1_pub.der
$ openssl rsa -in id1_pub.der -pubin -inform DER -outform PEM -out id1_pub.pem
~~~
**次は、ID 2 に適用できます。**
~~~
$ pkcs15-tool --read-certificate 2 --verify-pin --auth-id 2 --output id2_cert.pem
$ openssl x509 -in id2_cert.pem -pubkey -noout -out id2_pub.pem
~~~
又は
~~~
$ pkcs11-tool --slot 1 --login --read-object --id 2 --type cert --output-file id2_cert.der
$ openssl x509 -in id2_cert.der -inform DER -pubkey -noout -out id2_pub.pem
~~~
もしくは
~~~
$ pkcs11-tool --slot 1 --login --read-object --id 2 --type pubkey --output-file id2_pub.der
$ openssl rsa -in id2_pub.der -pubin -inform DER -outform PEM -out id2_pub.pem
~~~
### 証明書チェーンを確認する
~~~
$ openssl verify -CAfile id3_cert.pem id1_cert.pem
id1_cert.pem: OK
$ openssl verify -CAfile id4_cert.pem id2_cert.pem
id2_cert.pem: OK
~~~
### ハッシュを作る
~~~
$ pkcs11-tool --hash --input-file plain.txt --output-file plain.txt.sha1
~~~
### 電子署名する
#### pkcs15-crypt で署名
~~~
$ pkcs15-crypt --sign --key 1 --input plain.txt.sha1 --pkcs1 --output plain.txt.sha1.15id1.sig
$ pkcs15-crypt --sign --key 2 --input plain.txt.sha1 --pkcs1 --output plain.txt.sha1.15id2.sig
~~~
#### pkcs11-tool で署名
~~~
$ pkcs11-tool --id 1 --sign --input-file plain.txt.sha1 --output-file plain.txt.sha1.11id1.sig
$ pkcs11-tool --slot 1 --id 2 --sign --input-file plain.txt.sha1 --output-file plain.txt.sha1.11id2.sig
～～～
Please enter context specific PIN:   <<<- これが何か分からない為、Ctrl+C で終了しました。
~~~
### 電子署名を確認する
#### openssl で確認
~~~
$ openssl pkeyutl -verify -in plain.txt.sha1 -sigfile plain.txt.sha1.15id1.sig -inkey id1_pub.pem -pubin
$ openssl pkeyutl -verify -in plain.txt.sha1 -sigfile plain.txt.sha1.15id2.sig -inkey id2_pub.pem -pubin
$ openssl pkeyutl -verify -in plain.txt.sha1 -sigfile plain.txt.sha1.11id1.sig -inkey id1_pub.pem -pubin
~~~
#### pkcs11-tool で確認
~~~
$ pkcs11-tool --id 1 --verify --input-file plain.txt.sha1 --signature-file plain.txt.sha1.15id1.sig
$ pkcs11-tool --slot 1 --login --id 2 --verify --input-file plain.txt.sha1 --signature-file plain.txt.sha1.15id2.sig
$ pkcs11-tool --id 1 --verify --input-file plain.txt.sha1 --signature-file plain.txt.sha1.11id1.sig
~~~
### X509v3 Subject Alternative Name を UTF8 で表示する。
~~~
$ openssl asn1parse -in id2_cert.pem
  ～～～
  614:d=5  hl=2 l=   3 prim: OBJECT            :X509v3 Subject Alternative Name
  619:d=5  hl=3 l= 213 prim: OCTET STRING      [HEX DUMP]:...
  ～～～
$ openssl asn1parse -in id2_cert.pem -strparse 619
~~~
# ssh 公開鍵認証の準備
ssh の公開鍵認証用にマイナンバーカードから ユーザ認証用公開鍵 を取り出します。
~~~
$ pkcs15-tool --read-certificate 1 --output id1_cert.pem
$ openssl x509 -in id1_cert.pem -pubkey -noout -out id1_pub.pem
$ ssh-keygen -f id1_pub.pem -i -m PKCS8 > id1_pub.ssh
~~~
# 参考

## 電子証明書/JPKI から公開鍵を読み出す について（pkcs15-tool）

上記、pkcs15-tool コマンドの 公開鍵を読み出す（ssh、RFC4716 を含む3項目）は --read-public-key および --read-ssh-key オプションを使用しています。これらのオプションの説明は共に Reads public key with ID \<arg\> となっており、指定した ID \<arg\> の公開鍵を読み出すものですので、電子証明書/JPKI から公開鍵を読み出す といったタイトルはふさわしくありません。

しかし、実際に ID 1、2 に対してコマンドを実行してみると、`pkcs15-tool --dump` の一覧に ID 1、2 の公開鍵があるにも関わらず、次のエラーにより読み出すことが出来ません。
~~~
$ pkcs15-tool --read-public-key 1
Using reader with a card: Sony FeliCa Port/PaSoRi 3.0 0
Public key enumeration failed: Required ASN.1 object not found
~~~

コードを追ってみると、`asn1_decode() @ src/libopensc/asn1.c#1682` が `SC_ERROR_ASN1_OBJECT_NOT_FOUND` を返しており（`@ src/libopensc/asn1.c#1748`）、その原因を調べてみると、カードから読み出したもの（`data : sc_pkcs15_read_file() @ src/libopensc/pkcs15-pubkey.c#954`）が、期待している構造になっていない為のようです。

そこで、読み出したものを、`asn1_decode() @ src/libopensc/asn1.c#1682` に入った所でファイルに書き出し調べてみると、それは 電子証明書 と同じものでした。

何故、電子証明書が読み出されるのかは調べていません（マイナンバーカードの仕様なのか、OpenSC とマイナンバーカードの相性なのか...）が、`read_public_key() @ src/tools/pkcs15-tool.c#783` は、公開鍵が見つからない場合、電子証明書からそれを読み出す流れになっているため、ID 3、4 に対してコマンドを実行すると、公開鍵が 電子証明書/JPKI から読み出されます。

実際、`read_public_key() @ src/tools/pkcs15-tool.c#783`  に、見つかった公開鍵は無かったことにする、次の様な力技パッチを当てると、ID 1、2 に対しても、表面上、元々のオプションの意味に沿った動作をするようになります。
~~~
diff -upr -x .git OpenSC.orig/src/tools/pkcs15-tool.c OpenSC/src/tools/pkcs15-tool.c
--- OpenSC.orig/src/tools/pkcs15-tool.c 2022-09-05 11:55:21.686510100 +0900
+++ OpenSC/src/tools/pkcs15-tool.c      2022-09-15 16:07:20.844507000 +0900
@@ -796,6 +796,11 @@ static int read_public_key(void)
	sc_pkcs15_hex_string_to_id(opt_pubkey, &id);

	r = sc_pkcs15_find_pubkey_by_id(p15card, &id, &obj);
+
+	if ( !strncmp( p15card->tokeninfo->label, "JPKI", 4 ) ) {i	/* JPKI */
+		r = SC_ERROR_OBJECT_NOT_FOUND;i				/* JPKI */
+	}								/* JPKI */
+
	if (r >= 0) {
		if (verbose)
			printf("Reading public key with ID '%s'\n", opt_pubkey);
@@ -967,6 +972,11 @@ static int read_ssh_key(void)
	sc_pkcs15_hex_string_to_id(opt_pubkey, &id);

	r = sc_pkcs15_find_pubkey_by_id(p15card, &id, &obj);
+
+	if ( !strncmp( p15card->tokeninfo->label, "JPKI", 4 ) ) {	/* JPKI */
+		r = SC_ERROR_OBJECT_NOT_FOUND;				/* JPKI */
+	}								/* JPKI */
+
	if (r >= 0) {
		if (verbose)
			fprintf(stderr,"Reading ssh key with ID '%s'\n", opt_pubkey);
~~~
## 力技パッチ適用後のコマンド実行
~~~
$ pkcs15-tool --read-public-key 1
$ pkcs15-tool --read-public-key 2 --verify --auth-id 2
~~~
~~~
$ pkcs15-tool --read-ssh-key 1
$ pkcs15-tool --read-ssh-key 2 --verify --auth-id 2
~~~
~~~
$ pkcs15-tool --read-ssh-key 1 --rfc4716
$ pkcs15-tool --read-ssh-key 2 --rfc4716 --verify --auth-id 2
~~~

※ pkcs11-tool は --read-object --id 1 --type pubkey オプションで公開鍵の読み出し可能ですが、こちらについては読み出しが、公開鍵からされているのか、電子証明書からされているのか調べていません。
