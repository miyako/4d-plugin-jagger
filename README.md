![version](https://img.shields.io/badge/version-20%2B-E23089)
![platform](https://img.shields.io/static/v1?label=platform&message=mac-intel%20|%20mac-arm%20|%20win-64&color=blue)
[![license](https://img.shields.io/github/license/miyako/4d-plugin-jagger)](LICENSE)
![downloads](https://img.shields.io/github/downloads/miyako/4d-plugin-jagger/total)

# 4d-plugin-jagger
形態素解析器

## aknowlegements

* http://www.tkl.iis.u-tokyo.ac.jp/~ynaga/jagger/index.ja.html

## 変更箇所

* `stdin`を`dup2`で代用
* `stdout`を`std::ostringstream`で代用
* Windows対応
  * `mmap`
  * `munmap`
  * `open`
  * `lseek`

## モデルの管理

```4d
var $model : 4D.Folder
$model:=Jagger get model()  
$model:=Jagger set model(Folder("/RESOURCES/kyoto+kwdlc"))
```

デフォルトの`model`はプラグインに収録

## 辞書の更新

```4d
$model:=Folder(fk desktop folder).folder("custom_model")
$user:=File("/RESOURCES/user")
$train:=File("/RESOURCES/train.JAG")
$status:=Jagger train($model; $train; $user)  //; $dict)
```

デフォルトの`dict`はプラグインに収録

## 形態素解析

```4d
$split:=Jagger split("お世話になっております。")
$tokenize:=Jagger tokenize("お世話になっております。")
```
