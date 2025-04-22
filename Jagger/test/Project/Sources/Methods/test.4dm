//%attributes = {}
var $model : 4D:C1709.Folder
$model:=Jagger get model  //default model is embedded in plugin

//$split:=Jagger split("お世話になっております。")
$tokenize:=Jagger tokenize("お世話になっております。")

$tokenize:=Jagger tokenize("Jagger は、辞書に基づく単語分割のための最長一致法と、機械学習の分類器の事前計算に着想を得た、特徴パターンに基づく高速・高精度・省メモリの形態素解析器です。")

If (False:C215)
	$model:=Jagger set model(Folder:C1567("/RESOURCES/kyoto+kwdlc"))
End if 