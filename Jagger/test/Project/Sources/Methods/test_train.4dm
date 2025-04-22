//%attributes = {"invisible":true}
$model:=Folder:C1567(fk user preferences folder:K87:10).parent.folder("Jagger").folder("model").folder("commands4D")

If (Not:C34($model.exists))
	
	$user:=File:C1566("/RESOURCES/user")  //csv,utf8,no empty lines
	$train:=File:C1566("/RESOURCES/train.JAG")  //csv,utf8,no empty lines
	
	$status:=Jagger train($model; $train; $user)
	
End if 