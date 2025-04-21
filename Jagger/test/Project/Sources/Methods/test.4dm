//%attributes = {}
var $model : 4D:C1709.Folder
$model:=Jagger get model  //default model is embedded in plugin

//$split:=Jagger split("お世話になっております。"*10)
$tokenize:=Jagger tokenize("お世話になっております。")

If (False:C215)
	$model:=Jagger set model(Folder:C1567("/RESOURCES/kyoto+kwdlc"))
End if 