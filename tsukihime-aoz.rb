#coding:cp932
# for Ruby 2.6.6
# ���P��arc.sar ����m�x���f�[�^�����o��
# 
#
# �U���f�[�^�͈ȉ����Q�l�ɂ��Ă��܂��B
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

	# �o�̓X�g���[�����Z�b�g
	def output(fp, title)
		@fp = fp
		self.reset()

		warn "\n# writer begin ======================================== "
		@fp << "���P - Route #{title} \nTYPE-MOON\n\n\n"
	end

	def section(str)
		@fp <<  "\n\n�m���匩�o���n#{str}�m���匩�o���I���n\n\n"
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

		# s20����X�^�[�g
		if label then
			warn "\n# loadcmd #{label}"
			i = search_point(label) 
		end

		line = ""
		while(@txt.size > i)
			line.gsub!("��","�\�\")	# �c�����΍�
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
			elsif line =~ /(���̃V�[���͈�x�\�����ꂽ���Ƃ�����܂�|�X�L�b�v���܂����H)/ then
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

				@fp <<  "\n\n�y�I�����z (FLAG #{label})\n"
				pool.each_pair { |k,v|
					@fp << "�@�@#{k} -- #{v}\n"
				}
				@fp <<  "\n\n"
				return

			elsif line =~ /^\*(\w+)$/ then
				key = $1
				warn "## *#{key} "
				label = key
				@fp <<  "\n\n�m�������n\n�m�������o���nFLAG #{key}�m�������o���I���n\n\n" if key =~ /^s\w+/

				if choose_msg.length > 1 then
					@fp << "�m���R�������n�I���F�@#{choose_msg}\n\n"
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

open("���P-���I.txt", "w:utf-8"){|fp|
	eng.output(fp, "���I")
	eng.run("eclipse")
}

open("���P-����.txt", "w:utf-8"){|fp|
	eng.output(fp, "����")
	eng.run("f123",	"���߂���Ɉ��A������B")
	eng.run("f208",	"�E�E�E�ق��ėl�q������B")
	eng.run("f212",	"�E�E�E����A����ς�C���������B")

	eng.run("f213",	"���߂���̎�`�������ɂ����B")
	eng.run("f211half",	"���ɍs���B")
	eng.run("f291",	"�������Ȃ��B")
	eng.run("f317",	"�������^�����B")

	eng.run("f318",	"���߂���̎�`��������B")
	eng.run("f417",	"���߂���ɉ�ɍs���B")
	eng.run("f420",	"�E�E�E�O�ɏo�Ă݂�B")
	eng.run("f427",	"�����ЂƂ܂������B")
	eng.run("f429",	"�E�E�E�C�Â����O�Ɏd���߂�B")
}


open("���P-�Ő�.txt", "w:utf-8"){|fp|
	eng.output(fp, "�Ő�")
	eng.setflag("%cleared")
	eng.setflag("%flg6")

#	eng.run("f21",	"�z�[�����[���܂ł��Ɛ����B���͋����ɒ��s���ׂ���")
#	eng.run("f25",	"�����Ɏc���ĐH�����Ƃ�")
	eng.run("f32",	"����������o������߂āA���~�ɋA�邱�Ƃɂ��悤")
	eng.run("f39",	"���C���������̎q�̎���") 
	eng.run("f44",	"�����ő�l�������Ă��悤")
	eng.run("f48",	"��l��������")

	eng.run("f124",	"��l�Ɉ��A������")
	eng.reset()
	eng.run("f208",	"�E�E�E�ق��ėl�q������")
	eng.run("f212",	"�E�E�E����A����ς�C��������")
	
	eng.run("f214",	"�Ő��ɉ�ɍs��")
	eng.run("f211half",	"���ɍs��")
	
	eng.run("f291",	"�������Ȃ�")
	eng.run("f317",	"�������^����")

	eng.run("f319",	"�Ő��̎�`��������")
	eng.run("f387",	"�Ő��ɉ�ɍs��")
	eng.run("f392",	"���k����")
	eng.run("f395",	"���e�̕����ɍs��")
	eng.run("f397",	"��̊X�ɏo�Ă݂�")
	eng.run("f401",	"�Ő��ɂ��肢���Ă݂�")

	eng.run("f404",	"�E�E�E����Ȃ��̂ł͑S�R����Ȃ�")
	eng.reset()
	eng.run("f406",	"�E�E�E�Ȃ�Ō��Ȃ񂩂��߂��񂾂����H")
#	eng.run("f412",	"�H�t�̖��O������") #�� �g�D���[�G���h
	eng.run("f413",	"���߂̖��O������") #�� �O�b�h�G���h
}

open("���P-�H�t.txt", "w:utf-8"){|fp|
	eng.output(fp, "�H�t")
	eng.setflag("%flg6")
	eng.setflag("flgP")

	eng.run("f21",	"�z�[�����[���܂ł��Ɛ����B���͋����ɒ��s���ׂ����B")
	eng.run("f30",	"�����Ɏc���ĐH�����Ƃ�B")
	eng.run("f32",	"����������o������߂āA���~�ɋA�邱�Ƃɂ��悤�B")
#	eng.run("f38",	"���̏H�t�̎����B") #�� �A���N �� �V�G�� ���N���A��ɒǉ��B
	eng.run("f43",	"���Ԃɍs���ďH�t�Ƙb�����悤�B")
	eng.run("f46b",	"��l��������B") #�� �A���N �� �V�G�� ���N���A��ɒǉ��B

	eng.run("f304",	"�H�t�Ɉ��A������B")
	eng.run("f207",	"�|�˂����̎���q�˂�B")

	eng.run("f211half",	"���ɍs���B")
	eng.run("f237",	"�|�˂�{���ɍs���B")
	eng.run("f241",	"�|�˂�T���ɂ����B")
	eng.run("f243",	"�D���B")
	eng.run("f317",	"�������^�����B")

	eng.run("f326",	"�ǂ����ē]�Z���Ă����̂��₢�������B")
	eng.run("f330",	"�H�t�̋����ɍs���Ă݂�B")
	eng.run("f335",	"���Ԃɍs���B")

	#---- �H�t���[�g-------
	eng.run("f338a",	"����ɍs���Ă݂�B")
	eng.run("f345",	"���v�����狏�Ԃɍs�����B")
	eng.run("f348",	"�H�t�ɂ͍��̐������������Ă���B")
	eng.run("f352",	"���߂���̎�`��������B")
	eng.run("f354",	"����ł��A�H�t�Ɉ��A���炢�ł���Ǝv���B")
	eng.run("f356",	"�H�t�̋����ɍs���B")
	eng.run("f358half",	"�V�G���ɍ��̏o�����𑊒k����B")
	eng.run("f362",	"���������Ɍ��������ɂ����B")
	eng.run("f363",	"�E�E�E���ɂ́A�ł��Ȃ��B")
	eng.run("f368",	"���ق̓�K���B")
	eng.run("f372",	"�܂��͏H�t�̕������痣��悤�Ƃ����B")
	eng.run("f378",	"�ꑧ���āA���������Ă���ǂ�������B")
	eng.run("f380",	"�E�E�E�����~�߂�B")
	eng.run("f381",	"�E�E�E�H�t��ǂ��B")
	eng.run("f383",	"�E�E�E���ꂾ���́A�ł��Ȃ��B")
	eng.run("f385",	"�E�E�E�H�t�ɁA���̖���Ԃ��B") #�� �g�D���[�G���h
	eng.run("f384",	"�E�E�E����Ȏ��́A�ł��Ȃ��B") #�� �m�[�}���G���h
}

## - �A���N�F�C�h�E�u�������X�^�b�h ---------
open("���P-�A���N�F�C�h.txt", "w:utf-8"){ |fp|
	eng.output(fp, "�A���N�F�C�h")

	eng.run( "f20")
	eng.run( "f21",	"�z�[�����[���܂ł��Ɛ����B���͋����ɒ��s���ׂ���")
	eng.run( "f27",	"�L���ɏo�čl����")
	eng.run( "f32",	"����������o������߂āA���~�ɋA�邱�Ƃɂ��悤")
	# �� �A���N �� �V�G�� ���N���A��ɒǉ��B
	eng.run( "f38",	"���̏H�t�̎���")
	eng.run( "f43",	"���Ԃɍs���ďH�t�Ƙb�����悤")

	#�l�q�����ɍs�� �� �A���N �� �V�G�� ���N���A��ɒǉ��B
	#eng.run( "f47a")

	#
	eng.run( "f54",	"�H�t�Ɉ��A������")
	eng.run( "f60",	"�����łƂ낤")
	eng.run( "f66",	"����́A�����̈���������")
	eng.run( "f70",	"�H�t�ɂ��Ęb������")
	eng.run( "f76",	"�E�E�E���́A����")
	eng.run( "f81",	"�E�E�E����ł��A�R�C�c������Ă����Ȃ�")
	eng.run( "f82",	"�E�E�E���傤���Ȃ��B������������")
	eng.run( "f90",	"���������A�O�̗l�q�����ɂ����ׂ���")
	eng.run( "f95",	"�ł���΁A�f��A�������Ǆ����v")
	eng.run( "f99",	"�E�E�E����A�܂�����")
	eng.run( "f101",	"�l���֋삯���")
	eng.run( "f103",	"�����Ȃ������{��ׂ�������")
	eng.run( "f109",	"�����b���Ȃ��񂾂���A���߂đf���Ɏӂ�")
	#
	eng.run( "f113", "�E�E�E�X�ɏo�āA�T���Ă݂�")
	eng.run( "f118",	"�A���N�F�C�h��������Ȃ�")
	eng.run( "f130",	"�L���ɏo�Ęb�������悤")
	eng.run( "f136",	"��x���~�ɖ߂�")
	eng.run( "f146",	"�����͗z�C�Ɉ��A�����ď��a�܂��悤")
	eng.run( "f150",	"����������ɍs��")
	eng.run( "f154",	"����ł��A�Ő��ɂ͐����ɘb���Ă�����")
	eng.run( "f160",	"�E�E�E�H�t�̌����ʂ�ɂ���")
	eng.run( "f163",	"�E�E�E�d���Ȃ��B�A���N�F�C�h�ɕt��������")
	eng.run( "f164",	"����Ⴀ �킪�܂܂����炾��")
	eng.run( "f169",	"��Ԃ��B�f��قɘA��Ă�����")
	eng.run( "f174",	"�ł́A�A���N�F�C�h�́w�G�x���ďڂ���������")

	# �A���N�F�C�h���[�g-----------
	eng.run( "f180",	"�ɉ؊X��T����")
	eng.run( "f185",	"�E�E�E�܂��҂��Ă݂�")
	eng.run( "f187",	"�E�E�E�܂��҂��Ă݂�")
	eng.run( "f191",	"�E�E�E���̂܂܁A�����ɂ���")
	eng.run( "f195",	"���ʂł��A���N�F�C�h��T��������")

	#�񑩂���� �� ���P
	eng.run( "f52a", "�񑩂����")
	eng.run( "f53a", "�A���N�F�C�h��Y��Ȃ�")
}

open("���P-�V�G��.txt", "w:utf-8"){|fp|
	eng.output(fp, "�V�G��")
	eng.setflag("%flgD")
	eng.setflag("%flgE")
	eng.setflag("%ciel_regard")

	#
	eng.run("f22",	"�E�E�E�Ȃ񂾂��C�ɂȂ�B�l�q�����ɂ�����")
	eng.run("f27",	"�L���ɏo�čl����")
	eng.run("f33",	"�������������w�Z�Ɏc���Ă��悤")

#	eng.run("f38")		#���̏H�t�̎��� �� �A���N �� �V�G�� ���N���A��ɒǉ��B
	eng.run("f43",	"���Ԃɍs���ďH�t�Ƙb�����悤")
	eng.run("f56",	"��l�Ɉ��A������")
	eng.run("f64",	"�������Ɋ���o���ɂ�����")
	eng.run("f68", "�ԈႢ�Ȃ��A�������������������v")
	eng.run("f77",	"����A��΂ɋ��͂��Ȃ�")
	eng.run("f84",	"��͂蓦����ׂ����낤")
	eng.run("f87",	"�z�e���ɖ߂낤�Ǝv��")
	eng.run("f90",	"�������A�O�̗l�q�����ɂ����ׂ���")
	eng.run("f96",	"����A����ȉ������Ƃ�肠�����͂ł��Ȃ�")
	eng.run("f101", "�l���֑�����")
	eng.run("f103",	"�����Ȃ������{��ׂ�������")

	# -------------- �V�G�����[�g
	#
	eng.run("f219", "�f���Ɏӂ�")
	eng.run("f224",	"���̎���q�˂Ă݂�")
	eng.run("f227",	"�悵�A�H�ׂȂ�")
	eng.run("f232",	"����A���܂킸")
	eng.run("f119",	"�V�G����y��������Ȃ��B")
	eng.run("f132",	"������B����������ɂ܂���ċ����������I�v")
	eng.run("f246",	"����A�����Ă���y�ɉ�ɂ�����")
	eng.run("f251",	"�������Ɋ���o���ɂ�����")
	eng.run("f258",	"���̐l�́A��؂Ȑ�y��")
	eng.run("f262",	"����Ȏ����w�Z�ɍs����")
	eng.run("f269",	"��ÂɌ����Ԃ�")
	eng.run("f276",	"����ɍs���Ă݂�")
	eng.run("f279",	"�E�E�E���т�H�ׂɍs����")
	eng.run("f281",	"�E�E�E����A�ǂ��ł��悭�͂Ȃ�")
	eng.run("f286",	"���߂���̌����Ƃ��肾")
	eng.run("f293",	"���߂��A���߂����ǂ��Ԃ��Ȃ��ƁB")
	eng.run("f297",	"�E�E�E����ł��A������������")
	eng.run("f299",	"�O�ɓ�����")
	eng.run("f302",	"�E�E�E���K�l���Ƃ�Ȃ�")
	eng.run("f504",	"����̂܂܂̐�y���D����")

	# �� �O�b�h�G���h
	eng.run("f308",	"�A���N�F�C�h�ɏ]��")
	eng.run("f310",	"�A���N�F�C�h�ɂ͏]��Ȃ�")
}
