//%attributes = {"invisible":true}
var $model : 4D:C1709.Folder
$model:=Folder:C1567(fk desktop folder:K87:19).folder("4dcommands")

If (Not:C34($model.exists))
	
	$user:=File:C1566("/RESOURCES/user")  //csv,utf8,no empty lines
	$train:=File:C1566("/RESOURCES/train.JAG")  //csv,utf8,no empty lines
	$status:=Jagger train($model; $train; $user)
	
End if 

$model:=Jagger get model  //default model is embedded in plugin
$model:=Jagger set model($model)