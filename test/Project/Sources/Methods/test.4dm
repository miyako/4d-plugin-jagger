//%attributes = {}
//$jagger:=Jagger split("お世話になっております。")
//$jagger:=Jagger tokenize("お世話になっております。")

$defaultmodel:=Jagger get model  //default model is embedded in plugin

$model:=Folder:C1567(fk desktop folder:K87:19).folder("4dcommands")
$model:=Jagger set model($model)
$jagger:=Jagger tokenize("QUIT 4Dコマンドは、カレントの4Dアプリケーションを終了してデスクトップに戻ります。")

SET TEXT TO PASTEBOARD:C523(JSON Stringify:C1217($jagger; *))

Jagger set model($defaultmodel)