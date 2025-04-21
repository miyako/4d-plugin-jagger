//%attributes = {}
$model:=Folder:C1567(fk desktop folder:K87:19).folder("custom_model")
$user:=File:C1566("/RESOURCES/user")
$train:=File:C1566("/RESOURCES/train.JAG")
$status:=Jagger train($model; $train; $user)  //; $dict)