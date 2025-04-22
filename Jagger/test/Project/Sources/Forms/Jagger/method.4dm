$event:=FORM Event:C1606

Case of 
	: ($event.code=On Load:K2:1)
		
		Form:C1466.tokens:={col: []; sel: Null:C1517; item: Null:C1517; pos: Null:C1517}
		
		Form:C1466.text:="Jagger は、辞書に基づく単語分割のための最長一致法と、機械学習の分類器の事前計算に着想を得た、特徴パターンに基づく高速・高精度・省メモリの形態素解析器です。"
		
		Form:C1466.model1:=True:C214
		Form:C1466.model2:=False:C215
		
		Form:C1466.models:={default: Jagger get model}
		Form:C1466.models.commands4D:=Folder:C1567(fk user preferences folder:K87:10).parent.folder("Jagger").folder("model").folder("commands4D")
		
End case 