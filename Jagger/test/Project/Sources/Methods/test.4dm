//%attributes = {}
$t:=Jagger split("お世話になっております。")

$t:=Jagger tokenize("お世話になっております。")

If (False:C215)
	$model:=Jagger get model
	$model:=Jagger set model(Folder:C1567("/RESOURCES/kyoto+kwdlc"))
End if 