#coding:cp932
# for Ruby 2.6.6
# 月姫のarc.sar からノベルデータを取り出す
# 
#
# 攻略データは以下を参考にしています。
# http://adusa-ciel.my.coocan.jp/tukihime/tukihime.htm
#

class Machine
	def initialize()
		@txt = open("DecodeScenario_nscript.txt").readlines()

		@index = {}
		for i in 0 .. @txt.length do
			next if @txt[i] !~ /^\*(.+?)$/
			@index[$1] = i 
		end

		@flags = []
	end

	# 出力ストリームをセット
	def output(fp, title)
		@fp = fp
		self.reset()

		warn "\n# writer begin ======================================== "
		@fp << "月姫 - Route #{title} \nTYPE-MOON\n\n\n"
	end

	def section(str)
		@fp <<  "\n\n［＃大見出し］#{str}［＃大見出し終わり］\n\n"
	end

	
	def setflag(s)
		@flags << s
	end
	def reset()
		@flags = []
	end

	def run(label, choose_msg = "")
		i=0
		stack = []

		# s20からスタート
		if label then
			warn "\n# loadcmd #{label}"
			i = search_point(label) 
		end

		line = ""
		while(@txt.size > i)
			line.gsub!("─","――")	# 縦書き対策
			line.gsub!(/!\w\d+/, "")

			if line =~ /^([ ]*;|!|#|quakex|add|sub|monocro|wave|mov|lsp|selgosub|numalias|arc|spi|effect|save|str|set|bg|wait|btn|reset|delay|cmp|waveloop|play|ld|cl|windoweffect|print|csp|quakey)/
				;
			elsif line =~ /^if (%[\w_]+).* goto \*(.+)/ then	# if %flgD>=1 goto *f230
				warn line
				conds = $1; pnt = $2
				
				flag = false
				@flags.each{ |k|
					next if !conds.include?(k)
					go = search_point(pnt)
					warn "### if match #{k} ; action #{pnt} ; goto #{go}"

					line = @txt[go]
					i = go
					flag = true
				}
				redo if flag
			elsif line =~ /^if / then
				;
			elsif line =~ /^$/ then
				;
			elsif line =~ /^br/ then
				@fp << "\n"
			elsif line =~ /(このシーンは一度表示されたことがあります|スキップしますか？)/ then
				;
			elsif line =~ /^inc (.+)$/ then
				@flags << $1
			elsif line =~ /^gosub \*(regard_update|right_phase)/ then
				;
			elsif line =~ /^return/
				exit if stack.empty?
				@fp << "\n"
				i = stack.pop()
#				warn "## return #{i}"
				line = @txt[i]; redo
			elsif line =~ /^skip (\d)+/ then
				go = i + $1.to_i
				warn "## skip/jmpto #{go} from [#{i}]"
				i = go
				line = @txt[go]; redo

			elsif line =~ /^goto \*([\w_]+)/ then
				key = $1.to_s
				go = search_point(key)
				warn "## goto #{key}/#{go} from [#{i}]"
				i = go
				line = @txt[go]; redo
			elsif line =~ /^gosub \*([\w_]+)/ then
				key = $1.to_s
				stack << i +1
				i = search_point(key)
				warn "## gosub #{key}/#{i} from #{stack.to_s}"
				line = @txt[i]; redo
			elsif line =~ /^(select)/
				pool = {}
				while(true)
					break if line !~ /^(?:select|\t)\t+"(.+?)", ?\*(\w+)/
					pool[ $1.to_s ] = $2.to_s
					i += 1
					line = @txt[i]
				end
				warn "## select " + pool.to_s

				@fp <<  "\n\n【選択肢】 (FLAG #{label})\n"
				pool.each_pair { |k,v|
					@fp << "　　#{k} -- #{v}\n"
				}
				@fp <<  "\n\n"
				return

			elsif line =~ /^\*(\w+)$/ then
				key = $1
				warn "## *#{key} "
				label = key
				@fp <<  "\n\n［＃改丁］\n［＃中見出し］FLAG #{key}［＃中見出し終わり］\n\n" if key =~ /^s\w+/

				if choose_msg.length > 1 then
					@fp << "［＃３字下げ］選択：　#{choose_msg}\n\n"
					choose_msg = ""
				end
		
			else
				line.gsub!(/\\$/,"")
				@fp <<  line
			end

			i += 1
			line = @txt[i]
		end
	end

	private
	def search_point(name)
		return (@txt.size - 1) if name =~ /title/		# goto EOF

		return @index[name] if @index.member?(name)
		raise RuntimeError, "label '#{name}' not found"
	end
end

eng = Machine.new()

open("月姫-月蝕.txt", "w:utf-8"){|fp|
	eng.output(fp, "月蝕")
	eng.run("eclipse")
}

open("月姫-琥珀.txt", "w:utf-8"){|fp|
	eng.output(fp, "琥珀")
	eng.run("f123",	"琥珀さんに挨拶をする。")
	eng.run("f208",	"・・・黙って様子を見る。")
	eng.run("f212",	"・・・いや、やっぱり気分が悪い。")

	eng.run("f213",	"琥珀さんの手伝いをしにいく。")
	eng.run("f211half",	"見に行く。")
	eng.run("f291",	"答えられない。")
	eng.run("f317",	"もちろん賛成だ。")

	eng.run("f318",	"琥珀さんの手伝いをする。")
	eng.run("f417",	"琥珀さんに会いに行く。")
	eng.run("f420",	"・・・外に出てみる。")
	eng.run("f427",	"──ひとまず引く。")
	eng.run("f429",	"・・・気づかれる前に仕留める。")
}


open("月姫-翡翠.txt", "w:utf-8"){|fp|
	eng.output(fp, "翡翠")
	eng.setflag("%cleared")
	eng.setflag("%flg6")

#	eng.run("f21",	"ホームルームまであと数分。今は教室に直行すべきだ")
#	eng.run("f25",	"教室に残って食事をとる")
	eng.run("f32",	"いいかげん覚悟をきめて、屋敷に帰ることにしよう")
	eng.run("f39",	"元気だった女の子の事だ") 
	eng.run("f44",	"自室で大人しくしていよう")
	eng.run("f48",	"大人しく眠る")

	eng.run("f124",	"二人に挨拶をする")
	eng.reset()
	eng.run("f208",	"・・・黙って様子を見る")
	eng.run("f212",	"・・・いや、やっぱり気分が悪い")
	
	eng.run("f214",	"翡翠に会いに行く")
	eng.run("f211half",	"見に行く")
	
	eng.run("f291",	"答えられない")
	eng.run("f317",	"もちろん賛成だ")

	eng.run("f319",	"翡翠の手伝いをする")
	eng.run("f387",	"翡翠に会いに行く")
	eng.run("f392",	"相談する")
	eng.run("f395",	"父親の部屋に行く")
	eng.run("f397",	"夜の街に出てみる")
	eng.run("f401",	"翡翠にお願いしてみる")

	eng.run("f404",	"・・・こんなものでは全然足りない")
	eng.reset()
	eng.run("f406",	"・・・なんで鍵なんかしめたんだっけ？")
#	eng.run("f412",	"秋葉の名前を叫ぶ") #→ トゥルーエンド
	eng.run("f413",	"琥珀の名前を叫ぶ") #→ グッドエンド
}

open("月姫-秋葉.txt", "w:utf-8"){|fp|
	eng.output(fp, "秋葉")
	eng.setflag("%flg6")
	eng.setflag("flgP")

	eng.run("f21",	"ホームルームまであと数分。今は教室に直行すべきだ。")
	eng.run("f30",	"教室に残って食事をとる。")
	eng.run("f32",	"いいかげん覚悟をきめて、屋敷に帰ることにしよう。")
#	eng.run("f38",	"妹の秋葉の事だ。") #→ アルク か シエル をクリア後に追加。
	eng.run("f43",	"居間に行って秋葉と話をしよう。")
	eng.run("f46b",	"大人しく眠る。") #→ アルク か シエル をクリア後に追加。

	eng.run("f304",	"秋葉に挨拶をする。")
	eng.run("f207",	"弓塚さつきの事を尋ねる。")

	eng.run("f211half",	"見に行く。")
	eng.run("f237",	"弓塚を捜しに行く。")
	eng.run("f241",	"弓塚を探しにいく。")
	eng.run("f243",	"好き。")
	eng.run("f317",	"もちろん賛成だ。")

	eng.run("f326",	"どうして転校してきたのか問いただす。")
	eng.run("f330",	"秋葉の教室に行ってみる。")
	eng.run("f335",	"居間に行く。")

	#---- 秋葉ルート-------
	eng.run("f338a",	"離れに行ってみる。")
	eng.run("f345",	"大丈夫だから居間に行こう。")
	eng.run("f348",	"秋葉には今の制服が似合っている。")
	eng.run("f352",	"琥珀さんの手伝いをする。")
	eng.run("f354",	"それでも、秋葉に挨拶ぐらいできると思う。")
	eng.run("f356",	"秋葉の教室に行く。")
	eng.run("f358half",	"シエルに昨夜の出来事を相談する。")
	eng.run("f362",	"──自分に決着をつけにいく。")
	eng.run("f363",	"・・・俺には、できない。")
	eng.run("f368",	"東館の二階だ。")
	eng.run("f372",	"まずは秋葉の部屋から離れようとした。")
	eng.run("f378",	"一息ついて、落ち着いてから追いかける。")
	eng.run("f380",	"・・・足を止める。")
	eng.run("f381",	"・・・秋葉を追う。")
	eng.run("f383",	"・・・それだけは、できない。")
	eng.run("f385",	"・・・秋葉に、この命を返す。") #→ トゥルーエンド
	eng.run("f384",	"・・・そんな事は、できない。") #→ ノーマルエンド
}

## - アルクェイド・ブリュンスタッド ---------
open("月姫-アルクェイド.txt", "w:utf-8"){ |fp|
	eng.output(fp, "アルクェイド")

	eng.run( "f20")
	eng.run( "f21",	"ホームルームまであと数分。今は教室に直行すべきだ")
	eng.run( "f27",	"廊下に出て考える")
	eng.run( "f32",	"いいかげん覚悟をきめて、屋敷に帰ることにしよう")
	# → アルク か シエル をクリア後に追加。
	eng.run( "f38",	"妹の秋葉の事だ")
	eng.run( "f43",	"居間に行って秋葉と話をしよう")

	#様子を見に行く → アルク か シエル をクリア後に追加。
	#eng.run( "f47a")

	#
	eng.run( "f54",	"秋葉に挨拶をする")
	eng.run( "f60",	"教室でとろう")
	eng.run( "f66",	"これは、何かの悪いユメだ")
	eng.run( "f70",	"秋葉について話をする")
	eng.run( "f76",	"・・・協力、する")
	eng.run( "f81",	"・・・それでも、コイツを放っておけない")
	eng.run( "f82",	"・・・しょうがない。少しだけだぞ")
	eng.run( "f90",	"──俺が、外の様子を見にいくべきだ")
	eng.run( "f95",	"できれば、断り、たいけど──」")
	eng.run( "f99",	"・・・いや、まだ早い")
	eng.run( "f101",	"ネロへ駆け寄る")
	eng.run( "f103",	"こうなったら大本を潰すだけだ")
	eng.run( "f109",	"事情を話せないんだから、せめて素直に謝る")
	#
	eng.run( "f113", "・・・街に出て、探してみる")
	eng.run( "f118",	"アルクェイドかもしれない")
	eng.run( "f130",	"廊下に出て話しかけよう")
	eng.run( "f136",	"一度屋敷に戻る")
	eng.run( "f146",	"ここは陽気に挨拶をして場を和ませよう")
	eng.run( "f150",	"今すぐ中庭に行く")
	eng.run( "f154",	"それでも、翡翠には正直に話しておこう")
	eng.run( "f160",	"・・・秋葉の言う通りにする")
	eng.run( "f163",	"・・・仕方ない。アルクェイドに付きあおう")
	eng.run( "f164",	"そりゃあ わがままだからだろ")
	eng.run( "f169",	"定番だ。映画館に連れていこう")
	eng.run( "f174",	"では、アルクェイドの『敵』ついて詳しく聞こう")

	# アルクェイドルート-----------
	eng.run( "f180",	"繁華街を探そう")
	eng.run( "f185",	"・・・まだ待ってみる")
	eng.run( "f187",	"・・・まだ待ってみる")
	eng.run( "f191",	"・・・このまま、公園にいる")
	eng.run( "f195",	"無駄でもアルクェイドを探すだけだ")

	#約束を守る → 月姫
	eng.run( "f52a", "約束を守る")
	eng.run( "f53a", "アルクェイドを忘れない")
}

open("月姫-シエル.txt", "w:utf-8"){|fp|
	eng.output(fp, "シエル")
	eng.setflag("%flgD")
	eng.setflag("%flgE")
	eng.setflag("%ciel_regard")

	#
	eng.run("f22",	"・・・なんだか気になる。様子を見にいこう")
	eng.run("f27",	"廊下に出て考える")
	eng.run("f33",	"もう少しだけ学校に残っていよう")

#	eng.run("f38")		#妹の秋葉の事だ → アルク か シエル をクリア後に追加。
	eng.run("f43",	"居間に行って秋葉と話をしよう")
	eng.run("f56",	"二人に挨拶をする")
	eng.run("f64",	"茶道室に顔を出しにいこう")
	eng.run("f68", "間違いなく、俺がおこした現実だ」")
	eng.run("f77",	"いや、絶対に協力しない")
	eng.run("f84",	"やはり逃げるべきだろう")
	eng.run("f87",	"ホテルに戻ろうと思う")
	eng.run("f90",	"─俺が、外の様子を見にいくべきだ")
	eng.run("f96",	"いや、あんな化け物とやりあう事はできない")
	eng.run("f101", "ネロへ走り寄る")
	eng.run("f103",	"こうなったら大本を潰すだけだ")

	# -------------- シエルルート
	#
	eng.run("f219", "素直に謝る")
	eng.run("f224",	"昨夜の事を尋ねてみる")
	eng.run("f227",	"よし、食べない")
	eng.run("f232",	"いや、かまわず")
	eng.run("f119",	"シエル先輩かもしれない。")
	eng.run("f132",	"隙あり。こっそり後ろにまわって脅かすしか！」")
	eng.run("f246",	"いや、嫌われても先輩に会いにいこう")
	eng.run("f251",	"茶道室に顔を出しにいこう")
	eng.run("f258",	"あの人は、大切な先輩だ")
	eng.run("f262",	"そんな事より学校に行こう")
	eng.run("f269",	"冷静に言い返す")
	eng.run("f276",	"裏庭に行ってみる")
	eng.run("f279",	"・・・昼飯を食べに行こう")
	eng.run("f281",	"・・・いや、どうでもよくはない")
	eng.run("f286",	"琥珀さんの言うとおりだ")
	eng.run("f293",	"だめだ、琥珀さんを追い返さないと。")
	eng.run("f297",	"・・・それでも、声が聞きたい")
	eng.run("f299",	"前に逃げる")
	eng.run("f302",	"・・・メガネをとらない")
	eng.run("f504",	"ありのままの先輩が好きだ")

	# → グッドエンド
	eng.run("f308",	"アルクェイドに従う")
	eng.run("f310",	"アルクェイドには従わない")
}
