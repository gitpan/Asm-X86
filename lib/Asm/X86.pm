package Asm::X86;

use warnings;
require Exporter;

@ISA = (Exporter);
@EXPORT = qw();
@EXPORT_OK = qw(
	@regs8_intel @regs16_intel @segregs_intel @regs32_intel @regs64_intel @regs_mm_intel
	@regs_intel @regs_fpu_intel
	@regs8_att @regs16_att @segregs_att @regs32_att @regs64_att @regs_mm_att
	@regs_att @regs_fpu_att
	@instr_intel @instr_att @instr
	is_reg_intel is_reg8_intel is_reg16_intel is_reg32_intel
		is_reg64_intel is_reg_mm_intel is_segreg_intel is_reg_fpu_intel
	is_reg_att is_reg8_att is_reg16_att is_reg32_att
		is_reg64_att is_reg_mm_att is_segreg_att is_reg_fpu_att
	is_reg is_reg8 is_reg16 is_reg32 is_reg64 is_reg_mm is_segreg is_reg_fpu
	is_instr_intel is_instr_att is_instr
	is_valid_16bit_addr_intel is_valid_32bit_addr_intel is_valid_64bit_addr_intel is_valid_addr_intel
	is_valid_16bit_addr_att is_valid_32bit_addr_att is_valid_64bit_addr_att is_valid_addr_att
	is_valid_16bit_addr is_valid_32bit_addr is_valid_64bit_addr is_valid_addr
	conv_att_addr_to_intel conv_intel_addr_to_att
	conv_att_instr_to_intel conv_intel_instr_to_att
	);

use strict;

=head1 NAME

Asm::X86 - List of instructions and registers of Intel x86-compatible processors,
 validating and converting instructions and memory references.

=head1 VERSION

Version 0.07

=cut

our $VERSION = '0.07';

=head1 DESCRIPTION

This module provides the user with the ability to check whether a given
string represents an x86 processor register or instruction. It also provides
lists of registers and instructions and allows to check if a given
expression is a valid addressing mode. Other subrotuines include converting
between AT&T and Intel syntaxes.

=head1 SYNOPSIS

    use Asm::X86 qw(@instr is_instr);

    print "YES" if is_instr ("MOV");

=head1 EXPORT

 Nothing is exported by default.

 The following functions are exported on request:
	is_reg_intel is_reg8_intel is_reg16_intel is_reg32_intel
		is_reg64_intel is_reg_mm_intel is_segreg_intel is_reg_fpu_intel
	is_reg_att is_reg8_att is_reg16_att is_reg32_att
		is_reg64_att is_reg_mm_att is_segreg_att is_reg_fpu_att
	is_reg is_reg8 is_reg16 is_reg32 is_reg64 is_reg_mm is_segreg is_reg_fpu
	is_instr_intel is_instr_att is_instr
	is_valid_16bit_addr_intel is_valid_32bit_addr_intel is_valid_64bit_addr_intel is_valid_addr_intel
	is_valid_16bit_addr_att is_valid_32bit_addr_att is_valid_64bit_addr_att is_valid_addr_att
	is_valid_16bit_addr is_valid_32bit_addr is_valid_64bit_addr is_valid_addr
	conv_att_addr_to_intel conv_intel_addr_to_att
	conv_att_instr_to_intel conv_intel_instr_to_att

 These check if the given string parameter belongs to the specified
 class of registers or instructions or is a vaild addressing mode.
 The "convert*" functions can be used to convert the given instruction (including the
  operands)/addressing mode between AT&T and Intel syntaxes.
 The "_intel" and "_att" suffixes mean the Intel and AT&T syntaxes, respectively.
 No suffix means either Intel or AT&T.

 The following arrays are exported on request:
	@regs8_intel @regs16_intel @segregs_intel @regs32_intel @regs64_intel @regs_mm_intel
	@regs_intel @regs_fpu_intel
	@regs8_att @regs16_att @segregs_att @regs32_att @regs64_att @regs_mm_att
	@regs_att @regs_fpu_att
	@instr_intel @instr_att @instr

 These contain all register and instruction mnemonic names as strings.
 The "_intel" and "_att" suffixes mean the Intel and AT&T syntaxes, respectively.
 No suffix means either Intel or AT&T.

=head1 DATA

=cut

sub add_percent(@);

=head2 @regs8_intel

 A list of 8-bit registers (as strings) in Intel syntax.

=cut

our @regs8_intel = (
		'al', 'bl', 'cl', 'dl', 'r8b', 'r9b', 'r10b', 'r11b',
		'r12b', 'r13b', 'r14b', 'r15b', 'sil', 'dil', 'spl', 'bpl',
		'ah', 'bh', 'ch', 'dh'
		);

=head2 @regs8_att

 A list of 8-bit registers (as strings) in AT&T syntax.

=cut

our @regs8_att = add_percent @regs8_intel;

=head2 @segregs_intel

 A list of segment registers (as strings) in Intel syntax.

=cut

our @segregs_intel = ( 'cs', 'ds', 'es', 'fs', 'gs', 'ss' );

=head2 @segregs_att

 A list of segment registers (as strings) in AT&T syntax.

=cut

our @segregs_att = add_percent @segregs_intel;

=head2 @regs16_intel

 A list of 16-bit registers (as strings), including the segment registers,  in Intel syntax.

=cut

our @regs16_intel = (
		'ax', 'bx', 'cx', 'dx', 'r8w', 'r9w', 'r10w', 'r11w',
		'r12w', 'r13w', 'r14w', 'r15w', 'si', 'di', 'sp', 'bp',
		@segregs_intel
		);

=head2 @regs16_att

 A list of 16-bit registers (as strings), including the segment registers, in AT&T syntax.

=cut

our @regs16_att = add_percent @regs16_intel;

my @addressable32 = (
		'eax',	'ebx', 'ecx', 'edx', 'esi', 'edi', 'esp', 'ebp',
		);

my @r32_in64 = (
		'r8d', 'r8l', 'r9d', 'r9l', 'r10d', 'r10l', 'r11d', 'r11l',
		'r12d', 'r12l', 'r13d', 'r13l', 'r14d', 'r14l', 'r15d', 'r15l',
		);

=head2 @regs32_intel

 A list of 32-bit registers (as strings) in Intel syntax.

=cut

our @regs32_intel = (
		@addressable32,
		'cr0', 'cr2', 'cr3', 'cr4',
		'dr0', 'dr1', 'dr2', 'dr3', 'dr6', 'dr7',
		@r32_in64
		);

=head2 @regs32_att

 A list of 32-bit registers (as strings) in AT&T syntax.

=cut

our @regs32_att = add_percent @regs32_intel;

=head2 @regs_fpu_intel

 A list of FPU registers (as strings) in Intel syntax.

=cut

our @regs_fpu_intel = (
		'st0', 'st1', 'st2', 'st3', 'st4', 'st5', 'st6', 'st7',
		);

=head2 @regs_fpu_att

 A list of FPU registers (as strings) in AT&T syntax.

=cut

our @regs_fpu_att = add_percent @regs_fpu_intel;

=head2 @regs64_intel

 A list of 64-bit registers (as strings) in Intel syntax.

=cut

our @regs64_intel = (
		'rax', 'rbx', 'rcx', 'rdx', 'r8', 'r9', 'r10', 'r11',
		'r12', 'r13', 'r14', 'r15', 'rsi', 'rdi', 'rsp', 'rbp', 'rip'
		);

=head2 @regs64_att

 A list of 64-bit registers (as strings) in AT&T syntax.

=cut

our @regs64_att = add_percent @regs64_intel;

=head2 @regs_mm_intel

 A list of multimedia (MMX/3DNow!/SSEn) registers (as strings) in Intel syntax.

=cut

our @regs_mm_intel = (
		'mm0', 'mm1', 'mm2', 'mm3', 'mm4', 'mm5', 'mm6', 'mm7',
		'xmm0', 'xmm1', 'xmm2', 'xmm3', 'xmm4', 'xmm5', 'xmm6', 'xmm7',
		'xmm8', 'xmm9', 'xmm10', 'xmm11', 'xmm12', 'xmm13', 'xmm14', 'xmm15'
		);


=head2 @regs_mm_att

 A list of multimedia (MMX/3DNow!/SSEn) registers (as strings) in AT&T syntax.

=cut

our @regs_mm_att = add_percent @regs_mm_intel;

=head2 @regs_intel

 A list of all x86 registers (as strings) in Intel syntax.

=cut

our @regs_intel = ( @regs8_intel, @regs16_intel, @regs32_intel,
			@regs64_intel, @regs_mm_intel, @regs_fpu_intel);

=head2 @regs_att

 A list of all x86 registers (as strings) in AT&T syntax.

=cut

our @regs_att = ( @regs8_att, @regs16_att, @regs32_att, @regs64_att, @regs_mm_att, @regs_fpu_att);


=head2 @instr_intel

 A list of all x86 instructions (as strings) in Intel syntax.

=cut

our @instr_intel = (
 'aaa', 'aad', 'aam', 'aas', 'adc', 'add', 'addpd', 'addps', 'addsd', 'addss',
 'addsubpd', 'addsubps', 'aesdec', 'aesdeclast', 'aesenc', 'aesenclast',
 'aesimc', 'aeskeygenassist', 'and', 'andnpd', 'andnps', 'andpd', 'andps',
 'arpl', 'bb0_reset', 'bb1_reset', 'blendpd', 'blendps', 'blendvpd',
 'blendvps', 'bound', 'bsf', 'bsr', 'bswap', 'bt', 'btc', 'btr', 'bts', 'call',
 'cbw', 'cdq', 'cdqe', 'clc', 'cld', 'clflush', 'clgi', 'cli', 'clts', 'cmc',
 'cmova', 'cmovae', 'cmovb', 'cmovbe', 'cmovc', 'cmove', 'cmovg', 'cmovge',
 'cmovl', 'cmovle', 'cmovna', 'cmovnae', 'cmovnb', 'cmovnbe', 'cmovnc',
 'cmovne', 'cmovng', 'cmovnge', 'cmovnl', 'cmovnle', 'cmovno', 'cmovnp',
 'cmovns', 'cmovnz', 'cmovo', 'cmovp', 'cmovpe', 'cmovpo', 'cmovs', 'cmovz',
 'cmp', 'cmpeqpd', 'cmpeqps', 'cmpeqsd', 'cmpeqss', 'cmplepd', 'cmpleps',
 'cmplesd', 'cmpless', 'cmpltpd', 'cmpltps', 'cmpltsd', 'cmpltss', 'cmpneqpd',
 'cmpneqps', 'cmpneqsd', 'cmpneqss', 'cmpnlepd', 'cmpnleps', 'cmpnlesd',
 'cmpnless', 'cmpnltpd', 'cmpnltps', 'cmpnltsd', 'cmpnltss', 'cmpordpd',
 'cmpordps', 'cmpordsd', 'cmpordss', 'cmppd', 'cmpps', 'cmpsb', 'cmpsd',
 'cmpsq', 'cmpss', 'cmpsw', 'cmpunordpd', 'cmpunordps', 'cmpunordsd',
 'cmpunordss', 'cmpxchg', 'cmpxchg16b', 'cmpxchg486', 'cmpxchg8b', 'comeqpd',
 'comeqps', 'comeqsd', 'comeqss', 'comfalsepd', 'comfalseps', 'comfalsesd',
 'comfalsess', 'comisd', 'comiss', 'comlepd', 'comleps', 'comlesd', 'comless',
 'comltpd', 'comltps', 'comltsd', 'comltss', 'comneqpd', 'comneqps',
 'comneqsd', 'comneqss', 'comnlepd', 'comnleps', 'comnlesd', 'comnless',
 'comnltpd', 'comnltps', 'comnltsd', 'comnltss', 'comordpd', 'comordps',
 'comordsd', 'comordss', 'compd', 'comps', 'comsd', 'comss', 'comtruepd',
 'comtrueps', 'comtruesd', 'comtruess', 'comueqpd', 'comueqps', 'comueqsd',
 'comueqss', 'comulepd', 'comuleps', 'comulesd', 'comuless', 'comultpd',
 'comultps', 'comultsd', 'comultss', 'comuneqpd', 'comuneqps', 'comuneqsd',
 'comuneqss', 'comunlepd', 'comunleps', 'comunlesd', 'comunless', 'comunltpd',
 'comunltps', 'comunltsd', 'comunltss', 'comunordpd', 'comunordps',
 'comunordsd', 'comunordss', 'cpuid', 'cpu_read', 'cpu_write', 'cqo', 'crc32',
 'cvtdq2pd', 'cvtdq2ps', 'cvtpd2dq', 'cvtpd2pi', 'cvtpd2ps', 'cvtph2ps',
 'cvtpi2pd', 'cvtpi2ps', 'cvtps2dq', 'cvtps2pd', 'cvtps2ph', 'cvtps2pi',
 'cvtsd2si', 'cvtsd2ss', 'cvtsi2sd', 'cvtsi2ss', 'cvtss2sd', 'cvtss2si',
 'cvttpd2dq', 'cvttpd2pi', 'cvttps2dq', 'cvttps2pi', 'cvttsd2si', 'cvttss2si',
 'cwd', 'cwde', 'daa', 'das', 'dec', 'div', 'divpd', 'divps', 'divsd', 'divss',
 'dmint', 'dppd', 'dpps', 'emms', 'enter', 'extractps', 'extrq', 'f2xm1',
 'fabs', 'fadd', 'faddp', 'fbld', 'fbstp', 'fchs', 'fclex', 'fcmovb',
 'fcmovbe', 'fcmove', 'fcmovnb', 'fcmovnbe', 'fcmovne', 'fcmovnu', 'fcmovu',
 'fcom', 'fcomi', 'fcomip', 'fcomp', 'fcompp', 'fcos', 'fdecstp', 'fdisi',
 'fdiv', 'fdivp', 'fdivr', 'fdivrp', 'femms', 'feni', 'ffree', 'ffreep',
 'fiadd', 'ficom', 'ficomp', 'fidiv', 'fidivr', 'fild', 'fimul', 'fincstp',
 'finit', 'fist', 'fistp', 'fisttp', 'fisub', 'fisubr', 'fld', 'fld1', 'fldcw',
 'fldenv', 'fldl2e', 'fldl2t', 'fldlg2', 'fldln2', 'fldpi', 'fldz', 'fmaddpd',
 'fmaddps', 'fmaddsd', 'fmaddss', 'fmsubpd', 'fmsubps', 'fmsubsd', 'fmsubss',
 'fmul', 'fmulp', 'fnclex', 'fndisi', 'fneni', 'fninit', 'fnmaddpd',
 'fnmaddps', 'fnmaddsd', 'fnmaddss', 'fnmsubpd', 'fnmsubps', 'fnmsubsd',
 'fnmsubss', 'fnop', 'fnsave', 'fnstcw', 'fnstenv', 'fnstsw', 'fpatan',
 'fprem', 'fprem1', 'fptan', 'frczpd', 'frczps', 'frczsd', 'frczss', 'frndint',
 'frstor', 'fsave', 'fscale', 'fsetpm', 'fsin', 'fsincos', 'fsqrt', 'fst',
 'fstcw', 'fstenv', 'fstp', 'fstsw', 'fsub', 'fsubp', 'fsubr', 'fsubrp',
 'ftst', 'fucom', 'fucomi', 'fucomip', 'fucomp', 'fucompp', 'fwait', 'fxam',
 'fxch', 'fxrstor', 'fxsave', 'fxtract', 'fyl2x', 'fyl2xp1', 'getsec',
 'haddpd', 'haddps', 'hint_nop0', 'hint_nop1', 'hint_nop10', 'hint_nop11',
 'hint_nop12', 'hint_nop13', 'hint_nop14', 'hint_nop15', 'hint_nop16',
 'hint_nop17', 'hint_nop18', 'hint_nop19', 'hint_nop2', 'hint_nop20',
 'hint_nop21', 'hint_nop22', 'hint_nop23', 'hint_nop24', 'hint_nop25',
 'hint_nop26', 'hint_nop27', 'hint_nop28', 'hint_nop29', 'hint_nop3',
 'hint_nop30', 'hint_nop31', 'hint_nop32', 'hint_nop33', 'hint_nop34',
 'hint_nop35', 'hint_nop36', 'hint_nop37', 'hint_nop38', 'hint_nop39',
 'hint_nop4', 'hint_nop40', 'hint_nop41', 'hint_nop42', 'hint_nop43',
 'hint_nop44', 'hint_nop45', 'hint_nop46', 'hint_nop47', 'hint_nop48',
 'hint_nop49', 'hint_nop5', 'hint_nop50', 'hint_nop51', 'hint_nop52',
 'hint_nop53', 'hint_nop54', 'hint_nop55', 'hint_nop56', 'hint_nop57',
 'hint_nop58', 'hint_nop59', 'hint_nop6', 'hint_nop60', 'hint_nop61',
 'hint_nop62', 'hint_nop63', 'hint_nop7', 'hint_nop8', 'hint_nop9',
 'hlt', 'hsubpd', 'hsubps', 'ibts', 'icebp', 'idiv', 'imul', 'in', 'inc',
 'insb', 'insd', 'insertps', 'insertq', 'insw', 'int', 'int01', 'int03',
 'int1', 'int3', 'into', 'invd', 'invept', 'invlpg', 'invlpga', 'invvpid',
 'iret', 'iretd', 'iretq', 'iretw', 'ja', 'jae', 'jb', 'jbe', 'jc', 'jcxz',
 'je', 'jecxz', 'jg', 'jge', 'jl', 'jle', 'jmp', 'jmpe', 'jna', 'jnae', 'jnb',
 'jnbe', 'jnc', 'jne', 'jng', 'jnge', 'jnl', 'jnle', 'jno', 'jnp', 'jns',
 'jnz', 'jo', 'jp', 'jpe', 'jpo', 'jrcxz', 'js', 'jz', 'lahf', 'lar', 'lddqu',
 'ldmxcsr', 'lds', 'lea', 'leave', 'les', 'lfence', 'lfs', 'lgdt', 'lgs',
 'lidt', 'lldt', 'lmsw', 'loadall', 'loadall286', 'lock', 'lodsb', 'lodsd', 'lodsq',
 'lodsw', 'loop', 'loope', 'loopne', 'loopnz', 'loopz', 'lsl', 'lss', 'ltr',
 'lzcnt', 'maskmovdqu', 'maskmovq', 'maxpd', 'maxps', 'maxsd', 'maxss',
 'mfence', 'minpd', 'minps', 'minsd', 'minss', 'monitor', 'montmul', 'mov',
 'movapd', 'movaps', 'movbe', 'movd', 'movddup', 'movdq2q', 'movdqa', 'movdqu',
 'movhlps', 'movhpd', 'movhps', 'movlhps', 'movlpd', 'movlps', 'movmskpd',
 'movmskps', 'movntdq', 'movntdqa', 'movnti', 'movntpd', 'movntps', 'movntq',
 'movntsd', 'movntss', 'movq', 'movq2dq', 'movsb', 'movsd', 'movshdup',
 'movsldup', 'movsq', 'movss', 'movsw', 'movsx', 'movsxd', 'movupd', 'movups',
 'movzx', 'mpsadbw', 'mul', 'mulpd', 'mulps', 'mulsd', 'mulss', 'mwait',
 'neg', 'nop', 'not', 'or', 'orpd', 'orps', 'out', 'outsb', 'outsd', 'outsw',
 'pabsb', 'pabsd', 'pabsw', 'packssdw', 'packsswb', 'packusdw', 'packuswb',
 'paddb', 'paddd', 'paddq', 'paddsb', 'paddsiw', 'paddsw', 'paddusb',
 'paddusw', 'paddw', 'palignr', 'pand', 'pandn', 'pause', 'paveb', 'pavgb',
 'pavgusb', 'pavgw', 'pblendvb', 'pblendw', 'pclmulhqhqdq', 'pclmulhqlqdq',
 'pclmullqhqdq', 'pclmullqlqdq', 'pclmulqdq', 'pcmov', 'pcmpeqb', 'pcmpeqd',
 'pcmpeqq', 'pcmpeqw', 'pcmpestri', 'pcmpestrm', 'pcmpgtb', 'pcmpgtd',
 'pcmpgtq', 'pcmpgtw', 'pcmpistri', 'pcmpistrm', 'pcomb', 'pcomd', 'pcomeqb',
 'pcomeqd', 'pcomeqq', 'pcomequb', 'pcomequd', 'pcomequq', 'pcomequw',
 'pcomeqw', 'pcomfalseb', 'pcomfalsed', 'pcomfalseq', 'pcomfalseub',
 'pcomfalseud', 'pcomfalseuq', 'pcomfalseuw', 'pcomfalsew', 'pcomgeb',
 'pcomged', 'pcomgeq', 'pcomgeub', 'pcomgeud', 'pcomgeuq', 'pcomgeuw',
 'pcomgew', 'pcomgtb', 'pcomgtd', 'pcomgtq', 'pcomgtub', 'pcomgtud',
 'pcomgtuq', 'pcomgtuw', 'pcomgtw', 'pcomleb', 'pcomled', 'pcomleq',
 'pcomleub', 'pcomleud', 'pcomleuq', 'pcomleuw', 'pcomlew', 'pcomltb',
 'pcomltd', 'pcomltq', 'pcomltub', 'pcomltud', 'pcomltuq', 'pcomltuw',
 'pcomltw', 'pcomneqb', 'pcomneqd', 'pcomneqq', 'pcomnequb', 'pcomnequd',
 'pcomnequq', 'pcomnequw', 'pcomneqw', 'pcomq', 'pcomtrueb', 'pcomtrued',
 'pcomtrueq', 'pcomtrueub', 'pcomtrueud', 'pcomtrueuq', 'pcomtrueuw',
 'pcomtruew', 'pcomub', 'pcomud', 'pcomuq', 'pcomuw', 'pcomw', 'pdistib',
 'permpd', 'permps', 'pextrb', 'pextrd', 'pextrq', 'pextrw', 'pf2id',
 'pf2iw', 'pfacc', 'pfadd', 'pfcmpeq', 'pfcmpge', 'pfcmpgt', 'pfmax',
 'pfmin', 'pfmul', 'pfnacc', 'pfpnacc', 'pfrcp', 'pfrcpit1', 'pfrcpit2',
 'pfrcpv', 'pfrsqit1', 'pfrsqrt', 'pfrsqrtv', 'pfsub', 'pfsubr', 'phaddbd',
 'phaddbq', 'phaddbw', 'phaddd', 'phadddq', 'phaddsw', 'phaddubd', 'phaddubq',
 'phaddubw', 'phaddudq', 'phadduwd', 'phadduwq', 'phaddw', 'phaddwd',
 'phaddwq', 'phminposuw', 'phsubbw', 'phsubd', 'phsubdq', 'phsubsw',
 'phsubw', 'phsubwd', 'pi2fd', 'pi2fw', 'pinsrb', 'pinsrd', 'pinsrq',
 'pinsrw', 'pmachriw', 'pmacsdd', 'pmacsdqh', 'pmacsdql', 'pmacssdd',
 'pmacssdqh', 'pmacssdql', 'pmacsswd', 'pmacssww', 'pmacswd', 'pmacsww',
 'pmadcsswd', 'pmadcswd', 'pmaddubsw', 'pmaddwd', 'pmagw', 'pmaxsb',
 'pmaxsd', 'pmaxsw', 'pmaxub', 'pmaxud', 'pmaxuw', 'pminsb', 'pminsd',
 'pminsw', 'pminub', 'pminud', 'pminuw', 'pmovmskb', 'pmovsxbd', 'pmovsxbq',
 'pmovsxbw', 'pmovsxdq', 'pmovsxwd', 'pmovsxwq', 'pmovzxbd', 'pmovzxbq',
 'pmovzxbw', 'pmovzxdq', 'pmovzxwd', 'pmovzxwq', 'pmuldq', 'pmulhriw',
 'pmulhrsw', 'pmulhrwa', 'pmulhrwc', 'pmulhuw', 'pmulhw', 'pmulld',
 'pmullw', 'pmuludq', 'pmvgezb', 'pmvlzb', 'pmvnzb', 'pmvzb', 'pop', 'popa',
 'popad', 'popaw', 'popcnt', 'popf', 'popfd', 'popfq', 'popfw', 'por',
 'pperm', 'prefetch', 'prefetchnta', 'prefetcht0', 'prefetcht1',
 'prefetcht2', 'prefetchw', 'protb', 'protd', 'protq', 'protw', 'psadbw',
 'pshab', 'pshad', 'pshaq', 'pshaw', 'pshlb', 'pshld', 'pshlq', 'pshlw',
 'pshufb', 'pshufd', 'pshufhw', 'pshuflw', 'pshufw', 'psignb', 'psignd',
 'psignw', 'pslld', 'pslldq', 'psllq', 'psllw', 'psrad', 'psraw', 'psrld',
 'psrldq', 'psrlq', 'psrlw', 'psubb', 'psubd', 'psubq', 'psubsb', 'psubsiw',
 'psubsw', 'psubusb', 'psubusw', 'psubw', 'pswapd', 'ptest', 'punpckhbw',
 'punpckhdq', 'punpckhqdq', 'punpckhwd', 'punpcklbw', 'punpckldq',
 'punpcklqdq', 'punpcklwd', 'push', 'pusha', 'pushad', 'pushaw', 'pushf',
 'pushfd', 'pushfq', 'pushfw', 'pxor', 'rcl', 'rcpps', 'rcpss', 'rcr',
 'rdm', 'rdmsr', 'rdpmc', 'rdshr', 'rdtsc', 'rdtscp', 'rep', 'ret', 'retf', 'retn',
 'rol', 'ror', 'roundpd', 'roundps', 'roundsd', 'roundss', 'rsdc', 'rsldt',
 'rsm', 'rsqrtps', 'rsqrtss', 'rsts', 'sahf', 'sal', 'salc', 'sar', 'sbb',
 'scasb', 'scasd', 'scasq', 'scasw', 'seta', 'setae', 'setb', 'setbe',
 'setc', 'sete', 'setg', 'setge', 'setl', 'setle', 'setna', 'setnae',
 'setnb', 'setnbe', 'setnc', 'setne', 'setng', 'setnge', 'setnl', 'setnle',
 'setno', 'setnp', 'setns', 'setnz', 'seto', 'setp', 'setpe', 'setpo',
 'sets', 'setz', 'sfence', 'sgdt', 'shl', 'shld', 'shr', 'shrd', 'shufpd',
 'shufps', 'sidt', 'skinit', 'sldt', 'smi', 'smint', 'smintold', 'smsw',
 'sqrtpd', 'sqrtps', 'sqrtsd', 'sqrtss', 'stc', 'std', 'stgi', 'sti',
 'stmxcsr', 'stosb', 'stosd', 'stosq', 'stosw', 'str', 'sub', 'subpd',
 'subps', 'subsd', 'subss', 'svdc', 'svldt', 'svts', 'swapgs', 'syscall',
 'sysenter', 'sysexit', 'sysret', 'test', 'ucomisd', 'ucomiss', 'ud0',
 'ud1', 'ud2', 'ud2a', 'ud2b', 'umov', 'unpckhpd', 'unpckhps', 'unpcklpd',
 'unpcklps', 'vaddpd', 'vaddps', 'vaddsd', 'vaddss', 'vaddsubpd',
 'vaddsubps', 'vaesdec', 'vaesdeclast', 'vaesenc', 'vaesenclast',
 'vaesimc', 'vaeskeygenassist', 'vandnpd', 'vandnps', 'vandpd', 'vandps',
 'vblendpd', 'vblendps', 'vblendvpd', 'vblendvps', 'vbroadcastf128',
 'vbroadcastsd', 'vbroadcastss', 'vcmpeqpd', 'vcmpeqps', 'vcmpeqsd',
 'vcmpeqss', 'vcmpeq_ospd', 'vcmpeq_osps', 'vcmpeq_ossd', 'vcmpeq_osss',
 'vcmpeq_uqpd', 'vcmpeq_uqps', 'vcmpeq_uqsd', 'vcmpeq_uqss', 'vcmpeq_uspd',
 'vcmpeq_usps', 'vcmpeq_ussd', 'vcmpeq_usss', 'vcmpfalsepd', 'vcmpfalseps',
 'vcmpfalsesd', 'vcmpfalsess', 'vcmpfalse_ospd', 'vcmpfalse_osps',
 'vcmpfalse_ossd', 'vcmpfalse_osss', 'vcmpgepd', 'vcmpgeps', 'vcmpgesd',
 'vcmpgess', 'vcmpge_oqpd', 'vcmpge_oqps', 'vcmpge_oqsd', 'vcmpge_oqss',
 'vcmpgtpd', 'vcmpgtps', 'vcmpgtsd', 'vcmpgtss', 'vcmpgt_oqpd', 'vcmpgt_oqps',
 'vcmpgt_oqsd', 'vcmpgt_oqss', 'vcmplepd', 'vcmpleps', 'vcmplesd', 'vcmpless',
 'vcmple_oqpd', 'vcmple_oqps', 'vcmple_oqsd', 'vcmple_oqss', 'vcmpltpd',
 'vcmpltps', 'vcmpltsd', 'vcmpltss', 'vcmplt_oqpd', 'vcmplt_oqps',
 'vcmplt_oqsd', 'vcmplt_oqss', 'vcmpneqpd', 'vcmpneqps', 'vcmpneqsd',
 'vcmpneqss', 'vcmpneq_oqpd', 'vcmpneq_oqps', 'vcmpneq_oqsd', 'vcmpneq_oqss',
 'vcmpneq_ospd', 'vcmpneq_osps', 'vcmpneq_ossd', 'vcmpneq_osss',
 'vcmpneq_uspd', 'vcmpneq_usps', 'vcmpneq_ussd', 'vcmpneq_usss',
 'vcmpngepd', 'vcmpngeps', 'vcmpngesd', 'vcmpngess', 'vcmpnge_uqpd',
 'vcmpnge_uqps', 'vcmpnge_uqsd', 'vcmpnge_uqss', 'vcmpngtpd', 'vcmpngtps',
 'vcmpngtsd', 'vcmpngtss', 'vcmpngt_uqpd', 'vcmpngt_uqps', 'vcmpngt_uqsd',
 'vcmpngt_uqss', 'vcmpnlepd', 'vcmpnleps', 'vcmpnlesd', 'vcmpnless',
 'vcmpnle_uqpd', 'vcmpnle_uqps', 'vcmpnle_uqsd', 'vcmpnle_uqss', 'vcmpnltpd',
 'vcmpnltps', 'vcmpnltsd', 'vcmpnltss', 'vcmpnlt_uqpd', 'vcmpnlt_uqps',
 'vcmpnlt_uqsd', 'vcmpnlt_uqss', 'vcmpordpd', 'vcmpordps', 'vcmpordsd',
 'vcmpordss', 'vcmpord_spd', 'vcmpord_sps', 'vcmpord_ssd', 'vcmpord_sss',
 'vcmpors_spd', 'vcmpors_sps', 'vcmppd', 'vcmpps', 'vcmpsd', 'vcmpss',
 'vcmptruepd', 'vcmptrueps', 'vcmptruesd', 'vcmptruess', 'vcmptrue_uspd',
 'vcmptrue_usps', 'vcmptrue_ussd', 'vcmptrue_usss', 'vcmpunordpd',
 'vcmpunordps', 'vcmpunordsd', 'vcmpunordss', 'vcmpunord_spd',
 'vcmpunord_sps', 'vcmpunord_ssd', 'vcmpunord_sss', 'vcomisd',
 'vcomiss', 'vcvtdq2pd', 'vcvtdq2ps', 'vcvtpd2dq', 'vcvtpd2ps',
 'vcvtps2dq', 'vcvtps2pd', 'vcvtsd2si', 'vcvtsd2ss', 'vcvtsi2sd',
 'vcvtsi2ss', 'vcvtss2sd', 'vcvtss2si', 'vcvttpd2dq', 'vcvttps2dq',
 'vcvttsd2si', 'vcvttss2si', 'vdivpd', 'vdivps', 'vdivsd', 'vdivss',
 'vdppd', 'vdpps', 'verr', 'verw', 'vextractf128', 'vextractps', 'vfmaddpd',
 'vfmaddps', 'vfmaddsd', 'vfmaddss', 'vfmaddsubpd', 'vfmaddsubps',
 'vfmsubaddpd', 'vfmsubaddps', 'vfmsubpd', 'vfmsubps', 'vfmsubsd',
 'vfmsubss', 'vfnmaddpd', 'vfnmaddps', 'vfnmaddsd', 'vfnmaddss', 'vfnmsubpd',
 'vfnmsubps', 'vfnmsubsd', 'vfnmsubss', 'vhaddpd', 'vhaddps', 'vhsubpd',
 'vhsubps', 'vinsertf128', 'vinsertps', 'vlddqu', 'vldmxcsr', 'vldqqu',
 'vmaskmovdqu', 'vmaskmovpd', 'vmaskmovps', 'vmaxpd', 'vmaxps', 'vmaxsd',
 'vmaxss', 'vmcall', 'vmclear', 'vminpd', 'vminps', 'vminsd', 'vminss',
 'vmlaunch', 'vmload', 'vmmcall', 'vmovapd', 'vmovaps', 'vmovd', 'vmovddup',
 'vmovdqa', 'vmovdqu', 'vmovhlps', 'vmovhpd', 'vmovhps', 'vmovlhps',
 'vmovlpd', 'vmovlps', 'vmovmskpd', 'vmovmskps', 'vmovntdq', 'vmovntdqa',
 'vmovntpd', 'vmovntps', 'vmovntqq', 'vmovq', 'vmovqqa', 'vmovqqu',
 'vmovsd', 'vmovshdup', 'vmovsldup', 'vmovss', 'vmovupd', 'vmovups',
 'vmpsadbw', 'vmptrld', 'vmptrst', 'vmread', 'vmresume', 'vmrun', 'vmsave',
 'vmulpd', 'vmulps', 'vmulsd', 'vmulss', 'vmwrite', 'vmxoff', 'vmxon',
 'vorpd', 'vorps', 'vpabsb', 'vpabsd', 'vpabsw', 'vpackssdw', 'vpacksswb',
 'vpackusdw', 'vpackuswb', 'vpaddb', 'vpaddd', 'vpaddq', 'vpaddsb',
 'vpaddsw', 'vpaddusb', 'vpaddusw', 'vpaddw', 'vpalignr', 'vpand',
 'vpandn', 'vpavgb', 'vpavgw', 'vpblendvb', 'vpblendw', 'vpcmpeqb',
 'vpcmpeqd', 'vpcmpeqq', 'vpcmpeqw', 'vpcmpestri', 'vpcmpestrm', 'vpcmpgtb',
 'vpcmpgtd', 'vpcmpgtq', 'vpcmpgtw', 'vpcmpistri', 'vpcmpistrm', 'vperm2f128',
 'vpermil2pd', 'vpermil2ps', 'vpermilmo2pd', 'vpermilmo2ps', 'vpermilmz2pd',
 'vpermilmz2ps', 'vpermilpd', 'vpermilps', 'vpermiltd2pd', 'vpermiltd2ps',
 'vpextrb', 'vpextrd', 'vpextrq', 'vpextrw', 'vphaddd', 'vphaddsw',
 'vphaddw', 'vphminposuw', 'vphsubd', 'vphsubsw', 'vphsubw',
 'vpinsrb', 'vpinsrd', 'vpinsrq', 'vpinsrw', 'vpmaddubsw', 'vpmaddwd',
 'vpmaxsb', 'vpmaxsd', 'vpmaxsw', 'vpmaxub', 'vpmaxud', 'vpmaxuw',
 'vpminsb', 'vpminsd', 'vpminsw', 'vpminub', 'vpminud', 'vpminuw',
 'vpmovmskb', 'vpmovsxbd', 'vpmovsxbq', 'vpmovsxbw', 'vpmovsxdq',
 'vpmovsxwd', 'vpmovsxwq', 'vpmovzxbd', 'vpmovzxbq', 'vpmovzxbw',
 'vpmovzxdq', 'vpmovzxwd', 'vpmovzxwq', 'vpmuldq', 'vpmulhrsw', 'vpmulhuw',
 'vpmulhw', 'vpmulld', 'vpmullw', 'vpmuludq', 'vpor', 'vpsadbw', 'vpshufb',
 'vpshufd', 'vpshufhw', 'vpshuflw', 'vpsignb', 'vpsignd', 'vpsignw',
 'vpslld', 'vpslldq', 'vpsllq', 'vpsllw', 'vpsrad', 'vpsraw', 'vpsrld',
 'vpsrldq', 'vpsrlq', 'vpsrlw', 'vpsubb', 'vpsubd', 'vpsubq', 'vpsubsb',
 'vpsubsw', 'vpsubusb', 'vpsubusw', 'vpsubw', 'vptest', 'vpunpckhbw',
 'vpunpckhdq', 'vpunpckhqdq', 'vpunpckhwd', 'vpunpcklbw', 'vpunpckldq',
 'vpunpcklqdq', 'vpunpcklwd', 'vpxor', 'vrcpps', 'vrcpss', 'vroundpd',
 'vroundps', 'vroundsd', 'vroundss', 'vrsqrtps', 'vrsqrtss', 'vshufpd',
 'vshufps', 'vsqrtpd', 'vsqrtps', 'vsqrtsd', 'vsqrtss', 'vstmxcsr',
 'vsubpd', 'vsubps', 'vsubsd', 'vsubss', 'vtestpd', 'vtestps',
 'vucomisd', 'vucomiss', 'vunpckhpd', 'vunpckhps', 'vunpcklpd', 'vunpcklps',
 'vxorpd', 'vxorps', 'vzeroall', 'vzeroupper', 'wait', 'wbinvd', 'wrmsr',
 'wrshr', 'xadd', 'xbts', 'xchg', 'xcryptcbc', 'xcryptcfb', 'xcryptctr',
 'xcryptecb', 'xcryptofb', 'xgetbv', 'xlat', 'xlatb', 'xor', 'xorpd',
 'xorps', 'xrstor', 'xsave', 'xsetbv', 'xsha1', 'xsha256', 'xstore'
 		);

# non-FPU instructions with suffixes in AT&T syntax
my @att_suff_instr = (
		'mov' , 'and' , 'or'  , 'not', 'xor', 'neg', 'cmp', 'add' ,
		'sub' , 'push', 'test', 'lea', 'pop', 'inc', 'dec', 'idiv',
		'imul', 'sbb' , 'sal' , 'shl', 'sar', 'shr'
		);

# NOTE: no fi* instructions here
my @att_suff_instr_fpu = ( 'fadd', 'faddp', 'fbld', 'fbstp',
'fcom', 'fcomp', 'fcompp',
'fcomi', 'fcomip', 'fdiv', 'fdivr', 'fdivp', 'fdivrp',
 'fld', 'fmul', 'fmulp', 'fndisi',
 'fst', 'fstp', 'fsub', 'fsubr', 'fsubp', 'fsubrp',
'fucom', 'fucomp', 'fucompp', 'fucomi', 'fucomip');

sub add_att_suffix_instr(@);

=head2 @instr_att

 A list of all x86 instructions (as strings) in AT&T syntax.

=cut

our @instr_att = add_att_suffix_instr @instr_intel;

=head2 @instr

 A list of all x86 instructions (as strings) in Intel and AT&T syntax.

=cut

our @instr = (@instr_intel, @instr_att);

=head1 FUNCTIONS

=head2 is_reg_intel

 Checks if the given string parameter is a valid x86 register (any size) in Intel syntax.
 Returns 1 if yes.

=cut

sub is_reg_intel($) {

	my $elem = shift;
	foreach(@regs_intel) {
		return 1 if /^$elem$/i;
	}
	return 0;
}

=head2 is_reg_att

 Checks if the given string parameter is a valid x86 register (any size) in AT&T syntax.
 Returns 1 if yes.

=cut

sub is_reg_att($) {

	my $elem = shift;
	foreach(@regs_att) {
		return 1 if /^$elem$/i;
	}
	return 0;
}

=head2 is_reg

 Checks if the given string parameter is a valid x86 register (any size).
 Returns 1 if yes.

=cut

sub is_reg($) {

	my $elem = shift;
	return is_reg_intel($elem) | is_reg_att($elem);
}

=head2 is_reg8_intel

 Checks if the given string parameter is a valid x86 8-bit register in Intel syntax.
 Returns 1 if yes.

=cut

sub is_reg8_intel($) {

	my $elem = shift;
	foreach(@regs8_intel) {
		return 1 if /^$elem$/i;
	}
	return 0;
}

=head2 is_reg8_att

 Checks if the given string parameter is a valid x86 8-bit register in AT&T syntax.
 Returns 1 if yes.

=cut

sub is_reg8_att($) {

	my $elem = shift;
	foreach(@regs8_att) {
		return 1 if /^$elem$/i;
	}
	return 0;
}

=head2 is_reg8

 Checks if the given string parameter is a valid x86 8-bit register.
 Returns 1 if yes.

=cut

sub is_reg8($) {

	my $elem = shift;
	return is_reg8_intel($elem) | is_reg8_att($elem);
}

=head2 is_reg16_intel

 Checks if the given string parameter is a valid x86 16-bit register in Intel syntax.
 Returns 1 if yes.

=cut

sub is_reg16_intel($) {

	my $elem = shift;
	foreach(@regs16_intel) {
		return 1 if /^$elem$/i;
	}
	return 0;
}

=head2 is_reg16_att

 Checks if the given string parameter is a valid x86 16-bit register in AT&T syntax.
 Returns 1 if yes.

=cut

sub is_reg16_att($) {

	my $elem = shift;
	foreach(@regs16_att) {
		return 1 if /^$elem$/i;
	}
	return 0;
}

=head2 is_reg16

 Checks if the given string parameter is a valid x86 16-bit register.
 Returns 1 if yes.

=cut

sub is_reg16($) {

	my $elem = shift;
	return is_reg16_intel($elem) | is_reg16_att($elem);
}

=head2 is_segreg_intel

 Checks if the given string parameter is a valid x86 segment register in Intel syntax.
 Returns 1 if yes.

=cut

sub is_segreg_intel($) {

	my $elem = shift;
	foreach(@segregs_intel) {
		return 1 if /^$elem$/i;
	}
	return 0;
}

=head2 is_segreg_att

 Checks if the given string parameter is a valid x86 segment register in AT&T syntax.
 Returns 1 if yes.

=cut

sub is_segreg_att($) {

	my $elem = shift;
	foreach(@segregs_att) {
		return 1 if /^$elem$/i;
	}
	return 0;
}

=head2 is_segreg

 Checks if the given string parameter is a valid x86 segment register.
 Returns 1 if yes.

=cut

sub is_segreg($) {

	my $elem = shift;
	return is_segreg_intel($elem) | is_segreg_att($elem);
}

=head2 is_reg32_intel

 Checks if the given string parameter is a valid x86 32-bit register in Intel syntax.
 Returns 1 if yes.

=cut

sub is_reg32_intel($) {

	my $elem = shift;
	foreach(@regs32_intel) {
		return 1 if /^$elem$/i;
	}
	return 0;
}

=head2 is_reg32_att

 Checks if the given string parameter is a valid x86 32-bit register in AT&T syntax.
 Returns 1 if yes.

=cut

sub is_reg32_att($) {

	my $elem = shift;
	foreach(@regs32_att) {
		return 1 if /^$elem$/i;
	}
	return 0;
}

=head2 is_reg32

 Checks if the given string parameter is a valid x86 32-bit register.
 Returns 1 if yes.

=cut

sub is_reg32($) {

	my $elem = shift;
	return is_reg32_intel($elem) | is_reg32_att($elem);
}

=head2 is_addressable32_intel

 PRIVATE SUBROUTINE.
 Checks if the given string parameter is a valid x86 32-bit register which can be used
 	for addressing in Intel syntax.
 Returns 1 if yes.

=cut

sub is_addressable32_intel($) {

	my $elem = shift;
	foreach(@addressable32) {
		return 1 if /^$elem$/i;
	}
	return 0;
}

=head2 is_addressable32_att

 PRIVATE SUBROUTINE.
 Checks if the given string parameter is a valid x86 32-bit register which can be used
 	for addressing in AT&T syntax.
 Returns 1 if yes.

=cut

sub is_addressable32_att($) {

	my $elem = shift;
	foreach(@addressable32) {
		return 1 if "\%$_" =~ /^$elem$/i;
	}
	return 0;
}

=head2 is_addressable32

 PRIVATE SUBROUTINE.
 Checks if the given string parameter is a valid x86 32-bit register which can be used
 	for addressing.
 Returns 1 if yes.

=cut

sub is_addressable32($) {

	my $elem = shift;
	return is_addressable32_intel($elem) | is_addressable32_att($elem);
}

=head2 is_r32_in64_intel

 PRIVATE SUBROUTINE.
 Checks if the given string parameter is a valid x86 32-bit register which can only be used
 	in 64-bit mode (that is, checks if the given string parameter is a 32-bit
 	subregister of a 64-bit register).
 Returns 1 if yes.

=cut

sub is_r32_in64_intel($) {

	my $elem = shift;
	foreach(@r32_in64) {
		return 1 if /^$elem$/i;
	}
	return 0;
}

=head2 is_r32_in64_att

 PRIVATE SUBROUTINE.
 Checks if the given string parameter is a valid x86 32-bit register in Intel syntax
 	which can only be used in 64-bit mode (that is, checks if the given string
 	parameter is a 32-bit subregister of a 64-bit register).
 Returns 1 if yes.

=cut

sub is_r32_in64_att($) {

	my $elem = shift;
	foreach(@r32_in64) {
		return 1 if "\%$_" =~ /^$elem$/i;
	}
	return 0;
}

=head2 is_r32_in64

 PRIVATE SUBROUTINE.
 Checks if the given string parameter is a valid x86 32-bit register in AT&T syntax
 	which can only be used in 64-bit mode (that is, checks if the given string
 	parameter is a 32-bit subregister of a 64-bit register).
 Returns 1 if yes.

=cut

sub is_r32_in64($) {

	my $elem = shift;
	return is_r32_in64_intel($elem) | is_r32_in64_att($elem);
}

=head2 is_reg64_intel

 Checks if the given string parameter is a valid x86 64-bit register in Intel syntax.
 Returns 1 if yes.

=cut

sub is_reg64_intel($) {

	my $elem = shift;
	foreach(@regs64_intel) {
		return 1 if /^$elem$/i;
	}
	return 0;
}

=head2 is_reg64_att

 Checks if the given string parameter is a valid x86 64-bit register in AT&T syntax.
 Returns 1 if yes.

=cut

sub is_reg64_att($) {

	my $elem = shift;
	foreach(@regs64_att) {
		return 1 if /^$elem$/i;
	}
	return 0;
}

=head2 is_reg64

 Checks if the given string parameter is a valid x86 64-bit register.
 Returns 1 if yes.

=cut

sub is_reg64($) {

	my $elem = shift;
	return is_reg64_intel($elem) | is_reg64_att($elem);
}

=head2 is_reg_mm_intel

 Checks if the given string parameter is a valid x86 multimedia (MMX/3DNow!/SSEn)
 	register in Intel syntax.
 Returns 1 if yes.

=cut

sub is_reg_mm_intel($) {

	my $elem = shift;
	foreach(@regs_mm_intel) {
		return 1 if /^$elem$/i;
	}
	return 0;
}

=head2 is_reg_mm_att

 Checks if the given string parameter is a valid x86 multimedia (MMX/3DNow!/SSEn)
 	register in AT&T syntax.
 Returns 1 if yes.

=cut

sub is_reg_mm_att($) {

	my $elem = shift;
	foreach(@regs_mm_att) {
		return 1 if /^$elem$/i;
	}
	return 0;
}

=head2 is_reg_mm

 Checks if the given string parameter is a valid x86 multimedia (MMX/3DNow!/SSEn) register.
 Returns 1 if yes.

=cut

sub is_reg_mm($) {

	my $elem = shift;
	return is_reg_mm_intel($elem) | is_reg_mm_att($elem);
}

=head2 is_reg_fpu_intel

 Checks if the given string parameter is a valid x86 FPU register in Intel syntax.
 Returns 1 if yes.

=cut

sub is_reg_fpu_intel($) {

	my $elem = shift;
	foreach(@regs_fpu_intel) {
		return 1 if /^$elem$/i;
	}
	return 0;
}

=head2 is_reg_fpu_att

 Checks if the given string parameter is a valid x86 FPU register in AT&T syntax.
 Returns 1 if yes.

=cut

sub is_reg_fpu_att($) {

	my $elem = shift;
	foreach(@regs_fpu_att) {
		return 1 if /^$elem$/i;
	}
	return 0;
}

=head2 is_reg_fpu

 Checks if the given string parameter is a valid x86 FPU register.
 Returns 1 if yes.

=cut

sub is_reg_fpu($) {

	my $elem = shift;
	return is_reg_fpu_intel($elem) | is_reg_fpu_att($elem);
}

=head2 is_instr_intel

 Checks if the given string parameter is a valid x86 instruction in Intel syntax.
 Returns 1 if yes.

=cut

sub is_instr_intel($) {

	my $elem = shift;
	foreach(@instr_intel) {
		return 1 if /^$elem$/i;
	}
	return 0;
}

=head2 is_instr_att

 Checks if the given string parameter is a valid x86 instruction in AT&T syntax.
 Returns 1 if yes.

=cut

sub is_instr_att($) {

	my $elem = shift;
	foreach(@instr_att) {
		return 1 if /^$elem$/i;
	}
	return 0;
}

=head2 is_instr

 Checks if the given string parameter is a valid x86 instruction in any syntax.
 Returns 1 if yes.

=cut

sub is_instr($) {

	my $elem = shift;
	return is_instr_intel($elem) | is_instr_att($elem);
}

##############################################################################

=head2 is_valid_16bit_addr_intel

 Checks if the given string parameter (must contain the square braces)
  is a valid x86 16-bit addressing mode in Intel syntax.
 Returns 1 if yes.

=cut

sub is_valid_16bit_addr_intel($) {

	my $elem = shift;
	if ( $elem =~ /^(\w+):\s*\[\s*([\+\-]*)\s*(\w+)\s*\]$/o
		|| $elem =~ /^\[\s*(\w+)\s*:\s*([\+\-]*)\s*(\w+)\s*\]$/o ) {

		my ($r1, $r2, $sign) = ($1, $3, $2);

		return 0 if ( is_segreg_intel($r2) || ! is_segreg_intel($r1) );
		return 0 if ( (! is_reg16_intel($r2)) && (is_reg8_intel($r2) || is_segreg_intel($r2)
			|| is_reg32_intel($r2) || is_reg64_intel($r2) || is_reg_mm_intel($r2)) );

		if ( is_reg16_intel($r2) ) {

			return 0 if $sign =~ /-/o;
			# must be one of predefined registers
			if ( $r2 =~ /^bx$/io || $r2 =~ /^bp$/io
				|| $r2 =~ /^si$/io  || $r2 =~ /^di$/io )
			{
				return 1;
			}
			return 0;
		} else {
			# variable/number/constant is OK
			return 1;
		}
	}
	elsif ( $elem =~ /^(\w+):\s*\[\s*([\+\-]*)\s*(\w+)\s*([\+\-]+)\s*(\w+)\s*\]$/o
		|| $elem =~ /^\[\s*(\w+)\s*:\s*([\+\-]*)\s*(\w+)\s*([\+\-]+)\s*(\w+)\s*\]$/o ) {

		my ($r1, $r2, $r3, $r4, $sign) = ($1, $3, $4, $5, $2);

		return 0 if ( is_segreg_intel($r2) || is_segreg_intel($r4) || ! is_segreg_intel($r1) );
		return 0 if ( (! is_reg16_intel($r2)) && (is_reg8_intel($r2) || is_segreg_intel($r2)
			|| is_reg32_intel($r2) || is_reg64_intel($r2) || is_reg_mm_intel($r2)) );
		return 0 if ( (! is_reg16_intel($r4)) && (is_reg8_intel($r4) || is_segreg_intel($r4)
			|| is_reg32_intel($r4) || is_reg64_intel($r4) || is_reg_mm_intel($r4)) );

		if ( is_reg16_intel($r2) ) {

			return 0 if $sign =~ /-/o;
			# must be one of predefined registers
			if ( $r2 =~ /^bx$/io || $r2 =~ /^bp$/io
				|| $r2 =~ /^si$/io  || $r2 =~ /^di$/io )
			{
				if ( is_reg16_intel($r4) ) {

					return 0 if (($r2 =~ /^b.$/io && $r4 =~ /^b.$/io)
						|| ($r2 =~ /^.i$/io && $r4 =~ /^.i$/io));

					# must be one of predefined registers
					if ( ($r4 =~ /^bx$/io || $r4 =~ /^bp$/io
						|| $r4 =~ /^si$/io  || $r4 =~ /^di$/io)
						&& $r4 !~ /\b$r2\b/i
						&& $r3 !~ /-/o
						)
					{
						return 1;
					}
					return 0;
				} else {
					# variable/number/constant is OK
					return 1;
				}
			}
			return 0;
		} else {
			# variable/number/constant is OK
			if ( is_reg16_intel($r4) ) {

				# must be one of predefined registers
				if ( ($r4 =~ /^bx$/io || $r4 =~ /^bp$/io
					|| $r4 =~ /^si$/io  || $r4 =~ /^di$/io)
					&& $r3 !~ /-/o
				)
				{
					return 1;
				}
				return 0;
			} else {
				# variable/number/constant is OK
				return 1;
			}
		}
	}
	elsif ( $elem =~ /^(\w+):\s*\[\s*([\+\-]*)\s*(\w+)\s*([\+\-]+)\s*(\w+)\s*([\+\-]+)\s*(\w+)\s*\]$/o
		|| $elem =~ /^\[\s*(\w+)\s*:\s*([\+\-]*)\s*(\w+)\s*([\+\-]+)\s*(\w+)\s*([\+\-]+)\s*(\w+)\s*\]$/o ) {

		my ($r1, $r2, $r3, $r4, $r5, $r6, $sign) = ($1, $3, $4, $5, $6, $7, $2);

		return 0 if ( is_segreg_intel($r2) || is_segreg_intel($r4) || is_segreg_intel($r6) || ! is_segreg_intel($r1) );
		return 0 if ( (! is_reg16_intel($r2)) && (is_reg8_intel($r2) || is_segreg_intel($r2)
			|| is_reg32_intel($r2) || is_reg64_intel($r2) || is_reg_mm_intel($r2)) );
		return 0 if ( (! is_reg16_intel($r4)) && (is_reg8_intel($r4) || is_segreg_intel($r4)
			|| is_reg32_intel($r4) || is_reg64_intel($r4) || is_reg_mm_intel($r4)) );
		return 0 if ( (! is_reg16_intel($r6)) && (is_reg8_intel($r6) || is_segreg_intel($r6)
			|| is_reg32_intel($r6) || is_reg64_intel($r6) || is_reg_mm_intel($r6)) );

		if ( is_reg16_intel($r2) ) {

			return 0 if $sign =~ /-/o;
			# must be one of predefined registers
			if ( $r2 =~ /^bx$/io || $r2 =~ /^bp$/io
				|| $r2 =~ /^si$/io  || $r2 =~ /^di$/io )
			{
				if ( is_reg16_intel($r4) ) {

					return 0 if (($r2 =~ /^b.$/io && $r4 =~ /^b.$/io)
						|| ($r2 =~ /^.i$/io && $r4 =~ /^.i$/io));

					# must be one of predefined registers
					if ( ($r4 =~ /^bx$/io || $r4 =~ /^bp$/io
						|| $r4 =~ /^si$/io  || $r4 =~ /^di$/io)
						&& $r4 !~ /\b$r2\b/i
						&& $r3 !~ /-/o
						&& ! is_reg_intel($r6)
						)
					{
						return 1;
					}
					return 0;

				} elsif ( is_reg16_intel($r6) ) {

					return 0 if (($r2 =~ /^b.$/io && $r6 =~ /^b.$/io)
						|| ($r2 =~ /^.i$/io && $r6 =~ /^.i$/io));

					# must be one of predefined registers
					if ( ($r6 =~ /^bx$/io || $r6 =~ /^bp$/io
						|| $r6 =~ /^si$/io  || $r6 =~ /^di$/io)
						&& $r6 !~ /\b$r2\b/i
						&& $r5 !~ /-/o
						&& ! is_reg_intel($r4)
						)
					{
						return 1;
					}
					return 0;
				} else {
					# variable/number/constant is OK
					return 1;
				}
			}
			return 0;
		} else {
			# variable/number/constant is OK
			if ( is_reg16_intel($r4) ) {

				# must be one of predefined registers
				if ( $r4 =~ /^bx$/io || $r4 =~ /^bp$/io
					|| $r4 =~ /^si$/io  || $r4 =~ /^di$/io )
				{
					if ( is_reg16_intel($r6) ) {

						return 0 if (($r6 =~ /^b.$/io && $r4 =~ /^b.$/io)
							|| ($r6 =~ /^.i$/io && $r4 =~ /^.i$/io));

						# must be one of predefined registers
						if ( ($r6 =~ /^bx$/io || $r6 =~ /^bp$/io
							|| $r6 =~ /^si$/io  || $r6 =~ /^di$/io)
							&& $r6 !~ /\b$r4\b/i
							&& $r5 !~ /-/o
							)
						{
							return 1;
						}
						return 0;
					} else {
						# variable/number/constant is OK
						return 1;
					}
				}
				return 0;
			} else {
				# variable/number/constant is OK
				return 1;
			}
		}
	}
	elsif ( $elem =~ /^\[\s*([\+\-]*)\s*(\w+)\s*\]$/o ) {

		my ($r1, $sign) = ($2, $1);

		return 0 if ( is_segreg_intel($r1) );
		return 0 if ( (! is_reg16_intel($r1)) && (is_reg8_intel($r1) || is_segreg_intel($r1)
			|| is_reg32_intel($r1) || is_reg64_intel($r1) || is_reg_mm_intel($r1)) );

		if ( is_reg16_intel($r1) ) {

			return 0 if $sign =~ /-/o;
			# must be one of predefined registers
			if ( $r1 =~ /^bx$/io || $r1 =~ /^bp$/io
				|| $r1 =~ /^si$/io  || $r1 =~ /^di$/io )
			{
				return 1;
			}
			return 0;
		} else {
			# variable/number/constant is OK
			return 1;
		}
	}
	elsif ( $elem =~ /^\[\s*([\+\-]*)\s*(\w+)\s*([\+\-]+)\s*(\w+)\s*\]$/o ) {

		my ($r2, $r3, $r4, $sign) = ($2, $3, $4, $1);

		return 0 if ( is_segreg_intel($r2) || is_segreg_intel($r4) );
		return 0 if ( (! is_reg16_intel($r2)) && (is_reg8_intel($r2) || is_segreg_intel($r2)
			|| is_reg32_intel($r2) || is_reg64_intel($r2) || is_reg_mm_intel($r2)) );
		return 0 if ( (! is_reg16_intel($r4)) && (is_reg8_intel($r4) || is_segreg_intel($r4)
			|| is_reg32_intel($r4) || is_reg64_intel($r4) || is_reg_mm_intel($r4)) );

		if ( is_reg16_intel($r2) ) {

			return 0 if $sign =~ /-/o;
			# must be one of predefined registers
			if ( $r2 =~ /^bx$/io || $r2 =~ /^bp$/io
				|| $r2 =~ /^si$/io  || $r2 =~ /^di$/io )
			{
				if ( is_reg16_intel($r4) ) {

					return 0 if (($r2 =~ /^b.$/io && $r4 =~ /^b.$/io)
						|| ($r2 =~ /^.i$/io && $r4 =~ /^.i$/io));

					# must be one of predefined registers
					if ( ($r4 =~ /^bx$/io || $r4 =~ /^bp$/io
						|| $r4 =~ /^si$/io  || $r4 =~ /^di$/io)
						&& $r4 !~ /\b$r2\b/i
						&& $r3 !~ /-/o
						)
					{
						return 1;
					}
					return 0;
				} else {
					# variable/number/constant is OK
					return 1;
				}
			}
			return 0;
		} else {
			# variable/number/constant is OK
			if ( is_reg16_intel($r4) ) {

				# must be one of predefined registers
				if ( ($r4 =~ /^bx$/io || $r4 =~ /^bp$/io
					|| $r4 =~ /^si$/io  || $r4 =~ /^di$/io)
					&& $r3 !~ /-/o
				)
				{
					return 1;
				}
				return 0;
			} else {
				# variable/number/constant is OK
				return 1;
			}
		}
	}
	elsif ( $elem =~ /^\[\s*([\+\-]*)\s*(\w+)\s*([\+\-])\s*(\w+)\s*([\+\-]+)\s*(\w+)\s*\]$/o ) {

		my ($r2, $r3, $r4, $r5, $r6, $sign) = ($2, $3, $4, $5, $6, $1);

		return 0 if ( is_segreg_intel($r2) || is_segreg_intel($r4) || is_segreg_intel($r6) );
		return 0 if ( (! is_reg16_intel($r2)) && (is_reg8_intel($r2) || is_segreg_intel($r2)
			|| is_reg32_intel($r2) || is_reg64_intel($r2) || is_reg_mm_intel($r2)) );
		return 0 if ( (! is_reg16_intel($r4)) && (is_reg8_intel($r4) || is_segreg_intel($r4)
			|| is_reg32_intel($r4) || is_reg64_intel($r4) || is_reg_mm_intel($r4)) );
		return 0 if ( (! is_reg16_intel($r6)) && (is_reg8_intel($r6) || is_segreg_intel($r6)
			|| is_reg32_intel($r6) || is_reg64_intel($r6) || is_reg_mm_intel($r6)) );

		if ( is_reg16_intel($r2) ) {

			return 0 if $sign =~ /-/o;
			# must be one of predefined registers
			if ( $r2 =~ /^bx$/io || $r2 =~ /^bp$/io
				|| $r2 =~ /^si$/io  || $r2 =~ /^di$/io )
			{
				if ( is_reg16_intel($r4) ) {

					return 0 if (($r2 =~ /^b.$/io && $r4 =~ /^b.$/io)
						|| ($r2 =~ /^.i$/io && $r4 =~ /^.i$/io));

					# must be one of predefined registers
					if ( ($r4 =~ /^bx$/io || $r4 =~ /^bp$/io
						|| $r4 =~ /^si$/io  || $r4 =~ /^di$/io)
						&& $r4 !~ /\b$r2\b/i
						&& $r3 !~ /-/o
						&& ! is_reg_intel($r6)
						)
					{
						return 1;
					}
					return 0;

				} elsif ( is_reg16_intel($r6) ) {

					return 0 if (($r2 =~ /^b.$/io && $r6 =~ /^b.$/io)
						|| ($r2 =~ /^.i$/io && $r6 =~ /^.i$/io));

					# must be one of predefined registers
					if ( ($r6 =~ /^bx$/io || $r6 =~ /^bp$/io
						|| $r6 =~ /^si$/io  || $r6 =~ /^di$/io)
						&& $r6 !~ /\b$r2\b/i
						&& $r5 !~ /-/o
						&& ! is_reg_intel($r4)
						)
					{
						return 1;
					}
					return 0;
				} else {
					# variable/number/constant is OK
					return 1;
				}
			}
			return 0;
		} else {
			# variable/number/constant is OK
			if ( is_reg16_intel($r4) ) {

				# must be one of predefined registers
				if ( $r4 =~ /^bx$/io || $r4 =~ /^bp$/io
					|| $r4 =~ /^si$/io  || $r4 =~ /^di$/io )
				{
					if ( is_reg16_intel($r6) ) {

						return 0 if (($r6 =~ /^b.$/io && $r4 =~ /^b.$/io)
							|| ($r6 =~ /^.i$/io && $r4 =~ /^.i$/io));

						# must be one of predefined registers
						if ( ($r6 =~ /^bx$/io || $r6 =~ /^bp$/io
							|| $r6 =~ /^si$/io  || $r6 =~ /^di$/io)
							&& $r6 !~ /\b$r4\b/i
							&& $r5 !~ /-/o
							)
						{
							return 1;
						}
						return 0;
					} else {
						# variable/number/constant is OK
						return 1;
					}
				}
				return 0;
			} else {
				# variable/number/constant is OK
				return 1;
			}
		}
	}
	return 0;
}

=head2 is_valid_16bit_addr_att

 Checks if the given string parameter (must contain the parentheses)
  is a valid x86 16-bit addressing mode in AT&T syntax.
 Returns 1 if yes.

=cut

sub is_valid_16bit_addr_att($) {

	my $elem = shift;
	if ( $elem =~ /^([%\w]+):\s*\(\s*([+-]*)\s*([%\w]+)\s*\)$/o ) {

		my ($r1, $r2, $sign) = ($1, $3, $2);
		return 0 if (! is_segreg_att ($r1)) || is_segreg_att ($r2);
		return 0 if is_reg16_att($r2) && $r2 !~ /^%b.$/io && $r2 !~ /^%.i$/io;
		return 0 if is_reg16_att($r2) && $sign =~ /-/o;
		return 0 if is_reg_att($r2) && ! is_reg16_att($r2);
		return 1;
	}
	elsif ( $elem =~ /^([%\w]+):\s*\(\s*([%\w]+)\s*,\s*([%\w]+)\s*\)$/ ) {

		my ($r1, $r2, $r3) = ($1, $2, $3);
		return 0 if (! is_segreg_att ($r1)) || is_segreg_att ($r2) || is_segreg_att ($r3);
		return 0 if (! is_reg16_att($r2)) || (! is_reg16_att($r3));
		return 0 if is_reg16_att($r2) && $r2 !~ /^%b.$/io && $r2 !~ /^%.i$/io;
		return 0 if is_reg16_att($r3) && $r3 !~ /^%b.$/io && $r3 !~ /^%.i$/io;
		return 0 if is_reg16_att($r2) && is_reg16_att($r3) && (
			   $r2 !~ /^%b.$/io && $r3 !~ /^%b.$/io
			|| $r2 !~ /^%.i$/io && $r3 !~ /^%.i$/io
			);
		return 1;
	}
	elsif ( $elem =~ /^([%\w]+):\s*\(\s*([%\w]+)\s*,\s*([%\w]+)\s*,\s*(\d+)\s*\)$/o ) {

		# 'base, index, scale' not in 16-bit addresses
		return 0;
	}
	elsif ( $elem =~ /^([%\w]+):\s*\(\s*,\s*([%\w]+)\s*,\s*(\d+)\s*\)$/o ) {

		# 'index, scale' not in 16-bit addresses
		return 0;
	}
	elsif ( $elem =~ /^([%\w]+):\s*[+-]*\s*([%\w]+)\s*\(\s*([+-]*)\s*([%\w]+)\s*\)$/o ) {

		my ($r1, $r2, $var, $sign) = ($1, $4, $2, $3);
		return 0 if (! is_segreg_att ($r1)) || is_segreg_att ($r2);
		return 0 if is_reg16_att($r2) && $r2 !~ /^%b.$/io && $r2 !~ /^%.i$/io;
		return 0 if is_reg16_att($r2) && $sign =~ /-/o;
		return 0 if is_reg_att($r2) && ! is_reg16_att($r2);
		return 0 if is_reg_att($var);
		return 1;
	}
	elsif ( $elem =~ /^([%\w]+):\s*[+-]*\s*([%\w]+)\s*\(\s*([%\w]+)\s*,\s*([%\w]+)\s*\)$/o ) {

		my ($r1, $r2, $r3, $var) = ($1, $3, $4, $2);
		return 0 if (! is_segreg_att ($r1)) || is_segreg_att ($r2) || is_segreg_att ($r3);
		return 0 if (! is_reg16_att($r2)) || (! is_reg16_att($r3));
		return 0 if is_reg16_att($r2) && $r2 !~ /^%b.$/io && $r2 !~ /^%.i$/io;
		return 0 if is_reg16_att($r3) && $r3 !~ /^%b.$/io && $r3 !~ /^%.i$/io;
		return 0 if is_reg16_att($r2) && is_reg16_att($r3) && (
			   $r2 !~ /^%b.$/io && $r3 !~ /^%b.$/io
			|| $r2 !~ /^%.i$/io && $r3 !~ /^%.i$/io
			);
		return 0 if is_reg_att($var);
		return 1;
	}
	elsif ( $elem =~ /^([%\w]+):\s*[+-]*\s*([%\w]+)\s*\(\s*([%\w]+)\s*,\s*([%\w]+)\s*,\s*(\d+)\s*\)$/o ) {

		# 'base, index, scale' not in 16-bit addresses
		return 0;
	}
	elsif ( $elem =~ /^([%\w]+):\s*[+-]*\s*([%\w]+)\s*\(\s*,\s*([%\w]+)\s*,\s*(\d+)\s*\)$/o ) {

		# 'index, scale' not in 16-bit addresses
		return 0;
	}
	elsif ( $elem =~ /^([%\w]+):\s*[+-]*\s*([%\w]+)\s*\(\s*,\s*1\s*\)$/o ) {

		# special form: varname(1,)
		my ($r1, $var) = ($1, $2);
		return 0 if is_reg_att($var) || ! is_segreg_att ($r1);
		return 1;
	}
	elsif ( $elem =~ /^\(\s*([+-]*)\s*([%\w]+)\s*\)$/o ) {

		my ($r2, $sign) = ($2, $1);
		return 0 if is_segreg_att ($r2);
		return 0 if is_reg16_att($r2) && $r2 !~ /^%b.$/io && $r2 !~ /^%.i$/io;
		return 0 if is_reg_att($r2) && ! is_reg16_att($r2);
		return 0 if is_reg16_att($r2) && $sign =~ /-/o;
		return 1;
	}
	elsif ( $elem =~ /^\(\s*([%\w]+)\s*,\s*([%\w]+)\s*\)$/o ) {

		my ($r2, $r3) = ($1, $2);
		return 0 if is_segreg_att ($r2) || is_segreg_att ($r3);
		return 0 if (! is_reg16_att($r2)) || (! is_reg16_att($r3));
		return 0 if is_reg16_att($r2) && $r2 !~ /^%b.$/io && $r2 !~ /^%.i$/io;
		return 0 if is_reg16_att($r3) && $r3 !~ /^%b.$/io && $r3 !~ /^%.i$/io;
		return 0 if is_reg16_att($r2) && is_reg16_att($r3) && (
			   $r2 !~ /^%b.$/io && $r3 !~ /^%b.$/io
			|| $r2 !~ /^%.i$/io && $r3 !~ /^%.i$/io
			);
		return 1;
	}
	elsif ( $elem =~ /^\(\s*([%\w]+)\s*,\s*([%\w]+)\s*,\s*(\d+)\s*\)$/o ) {

		# 'base, index, scale' not in 16-bit addresses
		return 0;
	}
	elsif ( $elem =~ /^\(\s*,\s*([%\w]+)\s*,\s*(\d+)\s*\)$/o ) {

		# 'index, scale' not in 16-bit addresses
		return 0;
	}
	elsif ( $elem =~ /^[+-]*\s*([%\w]+)\s*\(\s*([+-]*)\s*([%\w]+)\s*\)$/o ) {

		my ($r2, $var, $sign) = ($3, $1, $2);
		return 0 if is_segreg_att ($r2);
		return 0 if is_reg16_att($r2) && $r2 !~ /^%b.$/io && $r2 !~ /^%.i$/io;
		return 0 if is_reg_att($r2) && ! is_reg16_att($r2);
		return 0 if is_reg16_att($r2) && $sign =~ /-/o;
		return 0 if is_reg_att($var);
		return 1;
	}
	elsif ( $elem =~ /^[+-]*\s*([%\w]+)\s*\(\s*([%\w]+)\s*,\s*([%\w]+)\s*\)$/o ) {

		my ($r2, $r3, $var) = ($2, $3, $1);
		return 0 if is_segreg_att ($r2) || is_segreg_att ($r3);
		return 0 if (! is_reg16_att($r2)) || (! is_reg16_att($r3));
		return 0 if is_reg16_att($r2) && $r2 !~ /^%b.$/io && $r2 !~ /^%.i$/io;
		return 0 if is_reg16_att($r3) && $r3 !~ /^%b.$/io && $r3 !~ /^%.i$/io;
		return 0 if is_reg16_att($r2) && is_reg16_att($r3) && (
			   $r2 !~ /^%b.$/io && $r3 !~ /^%b.$/io
			|| $r2 !~ /^%.i$/io && $r3 !~ /^%.i$/io
			);
		return 0 if is_reg_att($var);
		return 1;
	}
	elsif ( $elem =~ /^[+-]*\s*([%\w]+)\s*\(\s*([%\w]+)\s*,\s*([%\w]+)\s*,\s*(\d+)\s*\)$/o ) {

		# 'base, index, scale' not in 16-bit addresses
		return 0;
	}
	elsif ( $elem =~ /^[+-]*\s*([%\w]+)\s*\(\s*,\s*([%\w]+)\s*,\s*(\d+)\s*\)$/o ) {

		# 'index, scale' not in 16-bit addresses
		return 0;
	}
	elsif ( $elem =~ /^[+-]*\s*([%\w]+)\s*\(\s*,\s*1\s*\)$/o ) {

		# special form: varname(1,)
		my $var = $1;
		return 0 if is_reg_att($var);
		return 1;
	}
	return 0;
}

=head2 is_valid_16bit_addr

 Checks if the given string parameter (must contain the parentheses)
  is a valid x86 16-bit addressing mode in AT&T or Intel syntax.
 Returns 1 if yes.

=cut

sub is_valid_16bit_addr($) {

	my $elem = shift;
	return    is_valid_16bit_addr_intel($elem)
		| is_valid_16bit_addr_att($elem);
}

=head2 is_valid_32bit_addr_intel

 Checks if the given string parameter (must contain the square braces)
  is a valid x86 32-bit addressing mode in Intel syntax.
 Returns 1 if yes.

=cut

sub is_valid_32bit_addr_intel($) {

	my $elem = shift;
	# [seg:base+index*scale+disp]
	if (	$elem =~ /^\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]$/o
		|| $elem =~ /^(\w+)\s*:\s*\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]$/o) {

		my ($r1, $r2, $r3, $r4, $r5, $r6, $r7, $r8) = ($1, $2, $3, $4, $5, $6, $7, $8);

		return 0 if ( is_segreg_intel($r3) || is_segreg_intel($r6) || is_segreg_intel($r5)
			|| is_segreg_intel($r8) || ! is_segreg_intel($r1) );
		return 0 if ( (! is_addressable32_intel($r3)) && (is_reg8_intel($r3) || is_segreg_intel($r3)
			|| is_reg16_intel($r3) || is_reg64_intel($r3) || is_reg32_intel($r3)
			|| is_reg_mm_intel($r3) || is_reg_fpu_intel($r3)) );
		return 0 if ( (! is_addressable32_intel($r6)) && (is_reg8_intel($r6) || is_segreg_intel($r6)
			|| is_reg16_intel($r6) || is_reg64_intel($r6) || is_reg32_intel($r6)
			|| is_reg_mm_intel($r6) || is_reg_fpu_intel($r6)) );
		return 0 if ( (! is_addressable32_intel($r5)) && (is_reg8_intel($r5) || is_segreg_intel($r5)
			|| is_reg16_intel($r5) || is_reg64_intel($r5) || is_reg32_intel($r5)
			|| is_reg_mm_intel($r5) || is_reg_fpu_intel($r5)) );
		return 0 if ( (! is_addressable32_intel($r8)) && (is_reg8_intel($r8) || is_segreg_intel($r8)
			|| is_reg16_intel($r8) || is_reg64_intel($r8) || is_reg32_intel($r8)
			|| is_reg_mm_intel($r8) || is_reg_fpu_intel($r8)) );
		return 0 if ( is_reg_intel($r6) && is_reg_intel($r5) );
		return 0 if ( is_reg_intel($r3) && $r2 =~ /-/o );
		return 0 if ( (is_reg_intel($r5) || is_reg_intel($r6)) && $r4 =~ /-/o );
		return 0 if ( is_reg_intel($r8) && $r7 =~ /-/o );
		return 0 if ( $r5 =~ /\besp\b/io && $r6 =~ /\b\d+\b/o && $r6 != 1 );
		return 0 if ( $r6 =~ /\besp\b/io && $r5 =~ /\b\d+\b/o && $r5 != 1 );
		return 0 if ( is_reg_intel($r5) && $r6 =~ /\b\d+\b/o && $r6 != 1
			&& $r6 != 2 && $r6 != 4 && $r6 != 8);
		return 0 if ( is_reg_intel($r6) && $r5 =~ /\b\d+\b/o && $r5 != 1
			&& $r5 != 2 && $r5 != 4 && $r5 != 8);
		return 0 if ( is_reg_intel($r3) && (is_reg_intel($r5) || is_reg_intel($r6)) && is_reg_intel($r8) );

		return 1;
	}
	elsif (	$elem =~ /^\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]$/o
		|| $elem =~ /^(\w+)\s*:\s*\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]$/o) {

		my ($r1, $r2, $r3, $r7, $r8, $r4, $r5, $r6) = ($1, $2, $3, $4, $5, $6, $7, $8);

		return 0 if ( is_segreg_intel($r3) || is_segreg_intel($r6) || is_segreg_intel($r5)
			|| is_segreg_intel($r8) || ! is_segreg_intel($r1) );
		return 0 if ( (! is_addressable32_intel($r3)) && (is_reg8_intel($r3) || is_segreg_intel($r3)
			|| is_reg16_intel($r3) || is_reg64_intel($r3) || is_reg32_intel($r3)
			|| is_reg_mm_intel($r3) || is_reg_fpu_intel($r3)) );
		return 0 if ( (! is_addressable32_intel($r6)) && (is_reg8_intel($r6) || is_segreg_intel($r6)
			|| is_reg16_intel($r6) || is_reg64_intel($r6) || is_reg32_intel($r6)
			|| is_reg_mm_intel($r6) || is_reg_fpu_intel($r6)) );
		return 0 if ( (! is_addressable32_intel($r5)) && (is_reg8_intel($r5) || is_segreg_intel($r5)
			|| is_reg16_intel($r5) || is_reg64_intel($r5) || is_reg32_intel($r5)
			|| is_reg_mm_intel($r5) || is_reg_fpu_intel($r5)) );
		return 0 if ( (! is_addressable32_intel($r8)) && (is_reg8_intel($r8) || is_segreg_intel($r8)
			|| is_reg16_intel($r8) || is_reg64_intel($r8) || is_reg32_intel($r8)
			|| is_reg_mm_intel($r8) || is_reg_fpu_intel($r8)) );
		return 0 if ( is_reg_intel($r6) && is_reg_intel($r5) );
		return 0 if ( is_reg_intel($r3) && $r2 =~ /-/o );
		return 0 if ( (is_reg_intel($r5) || is_reg_intel($r6)) && $r4 =~ /-/o );
		return 0 if ( is_reg_intel($r8) && $r7 =~ /-/o );
		return 0 if ( $r5 =~ /\besp\b/io && $r6 =~ /\b\d+\b/o && $r6 != 1 );
		return 0 if ( $r6 =~ /\besp\b/io && $r5 =~ /\b\d+\b/o && $r5 != 1 );
		return 0 if ( is_reg_intel($r5) && $r6 =~ /\b\d+\b/o && $r6 != 1
			&& $r6 != 2 && $r6 != 4 && $r6 != 8);
		return 0 if ( is_reg_intel($r6) && $r5 =~ /\b\d+\b/o && $r5 != 1
			&& $r5 != 2 && $r5 != 4 && $r5 != 8);
		return 0 if ( is_reg_intel($r3) && (is_reg_intel($r5) || is_reg_intel($r6)) && is_reg_intel($r8) );

		return 1;
	}
	elsif (	$elem =~ /^\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]$/o
		|| $elem =~ /^(\w+)\s*:\s*\[\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]$/o) {

		my ($r1, $r4, $r5, $r6, $r2, $r3, $r7, $r8) = ($1, $2, $3, $4, $5, $6, $7, $8);

		return 0 if ( is_segreg_intel($r3) || is_segreg_intel($r6) || is_segreg_intel($r5)
			|| is_segreg_intel($r8) || ! is_segreg_intel($r1) );
		return 0 if ( (! is_addressable32_intel($r3)) && (is_reg8_intel($r3) || is_segreg_intel($r3)
			|| is_reg16_intel($r3) || is_reg64_intel($r3) || is_reg32_intel($r3)
			|| is_reg_mm_intel($r3) || is_reg_fpu_intel($r3)) );
		return 0 if ( (! is_addressable32_intel($r6)) && (is_reg8_intel($r6) || is_segreg_intel($r6)
			|| is_reg16_intel($r6) || is_reg64_intel($r6) || is_reg32_intel($r6)
			|| is_reg_mm_intel($r6) || is_reg_fpu_intel($r6)) );
		return 0 if ( (! is_addressable32_intel($r5)) && (is_reg8_intel($r5) || is_segreg_intel($r5)
			|| is_reg16_intel($r5) || is_reg64_intel($r5) || is_reg32_intel($r5)
			|| is_reg_mm_intel($r5) || is_reg_fpu_intel($r5)) );
		return 0 if ( (! is_addressable32_intel($r8)) && (is_reg8_intel($r8) || is_segreg_intel($r8)
			|| is_reg16_intel($r8) || is_reg64_intel($r8) || is_reg32_intel($r8)
			|| is_reg_mm_intel($r8) || is_reg_fpu_intel($r8)) );
		return 0 if ( is_reg_intel($r6) && is_reg_intel($r5) );
		return 0 if ( is_reg_intel($r3) && $r2 =~ /-/o );
		return 0 if ( (is_reg_intel($r5) || is_reg_intel($r6)) && $r4 =~ /-/o );
		return 0 if ( is_reg_intel($r8) && $r7 =~ /-/o );
		return 0 if ( $r5 =~ /\besp\b/io && $r6 =~ /\b\d+\b/o && $r6 != 1 );
		return 0 if ( $r6 =~ /\besp\b/io && $r5 =~ /\b\d+\b/o && $r5 != 1 );
		return 0 if ( is_reg_intel($r5) && $r6 =~ /\b\d+\b/o && $r6 != 1
			&& $r6 != 2 && $r6 != 4 && $r6 != 8);
		return 0 if ( is_reg_intel($r6) && $r5 =~ /\b\d+\b/o && $r5 != 1
			&& $r5 != 2 && $r5 != 4 && $r5 != 8);
		return 0 if ( is_reg_intel($r3) && (is_reg_intel($r5) || is_reg_intel($r6)) && is_reg_intel($r8) );

		return 1;
	}
	elsif (	$elem =~ /^\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]$/o
		|| $elem =~ /^(\w+)\s*:\s*\[\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]$/o) {

		my ($r1, $r4, $r5, $r6, $r2, $r3) = ($1, $2, $3, $4, $5, $6);

		return 0 if ( is_segreg_intel($r3) || is_segreg_intel($r6) || is_segreg_intel($r5)
			|| ! is_segreg_intel($r1) );
		return 0 if ( (! is_addressable32_intel($r3)) && (is_reg8_intel($r3) || is_segreg_intel($r3)
			|| is_reg16_intel($r3) || is_reg64_intel($r3) || is_reg32_intel($r3)
			|| is_reg_mm_intel($r3) || is_reg_fpu_intel($r3)) );
		return 0 if ( (! is_addressable32_intel($r6)) && (is_reg8_intel($r6) || is_segreg_intel($r6)
			|| is_reg16_intel($r6) || is_reg64_intel($r6) || is_reg32_intel($r6)
			|| is_reg_mm_intel($r6) || is_reg_fpu_intel($r6)) );
		return 0 if ( (! is_addressable32_intel($r5)) && (is_reg8_intel($r5) || is_segreg_intel($r5)
			|| is_reg16_intel($r5) || is_reg64_intel($r5) || is_reg32_intel($r5)
			|| is_reg_mm_intel($r5) || is_reg_fpu_intel($r5)) );
		return 0 if ( is_reg_intel($r6) && is_reg_intel($r5) );
		return 0 if ( is_reg_intel($r3) && $r2 =~ /-/o );
		return 0 if ( (is_reg_intel($r5) || is_reg_intel($r6)) && $r4 =~ /-/o );
		return 0 if ( $r5 =~ /\besp\b/io && $r6 =~ /\b\d+\b/o && $r6 != 1 );
		return 0 if ( $r6 =~ /\besp\b/io && $r5 =~ /\b\d+\b/o && $r5 != 1 );
		return 0 if ( is_reg_intel($r5) && $r6 =~ /\b\d+\b/o && $r6 != 1
			&& $r6 != 2 && $r6 != 4 && $r6 != 8);
		return 0 if ( is_reg_intel($r6) && $r5 =~ /\b\d+\b/o && $r5 != 1
			&& $r5 != 2 && $r5 != 4 && $r5 != 8);

		return 1;
	}
	elsif (	$elem =~ /^\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]$/o
		|| $elem =~ /^(\w+)\s*:\s*\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]$/o) {

		my ($r1, $r2, $r3, $r4, $r5, $r7, $r8) = ($1, $2, $3, $4, $5, $6, $7);

		return 0 if ( is_segreg_intel($r3) || is_segreg_intel($r5)
			|| is_segreg_intel($r8) || ! is_segreg_intel($r1) );
		return 0 if ( (! is_addressable32_intel($r3)) && (is_reg8_intel($r3) || is_segreg_intel($r3)
			|| is_reg16_intel($r3) || is_reg64_intel($r3) || is_reg32_intel($r3)
			|| is_reg_mm_intel($r3) || is_reg_fpu_intel($r3)) );
		return 0 if ( (! is_addressable32_intel($r5)) && (is_reg8_intel($r5) || is_segreg_intel($r5)
			|| is_reg16_intel($r5) || is_reg64_intel($r5) || is_reg32_intel($r5)
			|| is_reg_mm_intel($r5) || is_reg_fpu_intel($r5)) );
		return 0 if ( (! is_addressable32_intel($r8)) && (is_reg8_intel($r8) || is_segreg_intel($r8)
			|| is_reg16_intel($r8) || is_reg64_intel($r8) || is_reg32_intel($r8)
			|| is_reg_mm_intel($r8) || is_reg_fpu_intel($r8)) );
		return 0 if ( is_reg_intel($r3) && $r2 =~ /-/o );
		return 0 if ( is_reg_intel($r5) && $r4 =~ /-/o );
		return 0 if ( is_reg_intel($r8) && $r7 =~ /-/o );
		return 0 if ( is_reg_intel($r3) && is_reg_intel($r5) && is_reg_intel($r8) );

		return 1;
	}
	elsif (	$elem =~ /^\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]$/o
		|| $elem =~ /^(\w+)\s*:\s*\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]$/o) {

		my ($r1, $r2, $r3, $r4, $r5, $r6) = ($1, $2, $3, $4, $5, $6);

		return 0 if ( is_segreg_intel($r3) || is_segreg_intel($r6) || is_segreg_intel($r5)
			|| ! is_segreg_intel($r1) );
		return 0 if ( (! is_addressable32_intel($r3)) && (is_reg8_intel($r3) || is_segreg_intel($r3)
			|| is_reg16_intel($r3) || is_reg64_intel($r3) || is_reg32_intel($r3)
			|| is_reg_mm_intel($r3) || is_reg_fpu_intel($r3)) );
		return 0 if ( (! is_addressable32_intel($r6)) && (is_reg8_intel($r6) || is_segreg_intel($r6)
			|| is_reg16_intel($r6) || is_reg64_intel($r6) || is_reg32_intel($r6)
			|| is_reg_mm_intel($r6) || is_reg_fpu_intel($r6)) );
		return 0 if ( (! is_addressable32_intel($r5)) && (is_reg8_intel($r5) || is_segreg_intel($r5)
			|| is_reg16_intel($r5) || is_reg64_intel($r5) || is_reg32_intel($r5)
			|| is_reg_mm_intel($r5) || is_reg_fpu_intel($r5)) );
		return 0 if ( is_reg_intel($r6) && is_reg_intel($r5) );
		return 0 if ( is_reg_intel($r3) && $r2 =~ /-/o );
		return 0 if ( (is_reg_intel($r5) || is_reg_intel($r6)) && $r4 =~ /-/o );
		return 0 if ( $r5 =~ /\besp\b/io && $r6 =~ /\b\d+\b/o && $r6 != 1 );
		return 0 if ( $r6 =~ /\besp\b/io && $r5 =~ /\b\d+\b/o && $r5 != 1 );
		return 0 if ( is_reg_intel($r5) && $r6 =~ /\b\d+\b/o && $r6 != 1
			&& $r6 != 2 && $r6 != 4 && $r6 != 8);
		return 0 if ( is_reg_intel($r6) && $r5 =~ /\b\d+\b/o && $r5 != 1
			&& $r5 != 2 && $r5 != 4 && $r5 != 8);

		return 1;
	}
	elsif (	$elem =~ /^\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*\]$/o
		|| $elem =~ /^(\w+)\s*:\s*\[\s*([\+\-\(\)]*)\s*(\w+)\s*\]$/o) {

		my ($r1, $r2, $r3) = ($1, $2, $3);

		return 0 if ( is_segreg_intel($r3) || ! is_segreg_intel($r1) );
		return 0 if ( (! is_addressable32_intel($r3)) && (is_reg8_intel($r3) || is_segreg_intel($r3)
			|| is_reg16_intel($r3) || is_reg64_intel($r3) || is_reg32_intel($r3)
			|| is_reg_mm_intel($r3) || is_reg_fpu_intel($r3)) );
		return 0 if ( is_reg_intel($r3) && $r2 =~ /-/o );

		return 1;
	}
	elsif (	$elem =~ /^\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]$/o
		|| $elem =~ /^(\w+)\s*:\s*\[\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]$/o) {

		my ($r1, $r2, $r3, $r4) = ($1, $2, $3, $4);

		return 0 if ( is_segreg_intel($r3) || is_segreg_intel($r4) || ! is_segreg_intel($r1) );
		return 0 if ( (! is_addressable32_intel($r3)) && (is_reg8_intel($r3) || is_segreg_intel($r3)
			|| is_reg16_intel($r3) || is_reg64_intel($r3) || is_reg32_intel($r3)
			|| is_reg_mm_intel($r3) || is_reg_fpu_intel($r3)) );
		return 0 if ( (! is_addressable32_intel($r4)) && (is_reg8_intel($r4) || is_segreg_intel($r4)
			|| is_reg16_intel($r4) || is_reg64_intel($r4) || is_reg32_intel($r4)
			|| is_reg_mm_intel($r4) || is_reg_fpu_intel($r4)) );
		return 0 if ( is_reg_intel($r3) && is_reg_intel($r4) );
		return 0 if ( is_reg_intel($r3) && $r2 =~ /-/o );
		return 0 if ( (is_reg_intel($r3) || is_reg_intel($r4)) && $r2 =~ /-/o );
		return 0 if ( $r3 =~ /\besp\b/io && $r4 =~ /\b\d+\b/o && $r4 != 1 );
		return 0 if ( $r4 =~ /\besp\b/io && $r3 =~ /\b\d+\b/o && $r3 != 1 );
		return 0 if ( is_reg_intel($r3) && $r4 =~ /\b\d+\b/o && $r4 != 1
			&& $r4 != 2 && $r4 != 4 && $r4 != 8);
		return 0 if ( is_reg_intel($r4) && $r3 =~ /\b\d+\b/o && $r3 != 1
			&& $r3 != 2 && $r3 != 4 && $r3 != 8);

		return 1;
	}
	elsif (	$elem =~ /^\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]*)\s*(\w+)\s*\]$/o
		|| $elem =~ /^(\w+)\s*:\s*\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]*)\s*(\w+)\s*\]$/o) {

		my ($r1, $r2, $r3, $r4, $r5) = ($1, $2, $3, $4, $5);

		return 0 if ( is_segreg_intel($r3) || is_segreg_intel($r5) || ! is_segreg_intel($r1) );
		return 0 if ( (! is_addressable32_intel($r3)) && (is_reg8_intel($r3) || is_segreg_intel($r3)
			|| is_reg16_intel($r3) || is_reg64_intel($r3) || is_reg32_intel($r3)
			|| is_reg_mm_intel($r3) || is_reg_fpu_intel($r3)) );
		return 0 if ( (! is_addressable32_intel($r5)) && (is_reg8_intel($r5) || is_segreg_intel($r5)
			|| is_reg16_intel($r5) || is_reg64_intel($r5) || is_reg32_intel($r5)
			|| is_reg_mm_intel($r5) || is_reg_fpu_intel($r5)) );
		return 0 if ( is_reg_intel($r3) && $r2 =~ /-/o );
		return 0 if ( is_reg_intel($r5) && $r4 =~ /-/o );

		return 1;
	}
	elsif (	$elem =~ /^\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]$/o ) {

		my ($r2, $r3, $r4, $r5, $r6, $r7, $r8) = ($1, $2, $3, $4, $5, $6, $7);

		return 0 if ( is_segreg_intel($r3) || is_segreg_intel($r6) || is_segreg_intel($r5)
			|| is_segreg_intel($r8) );
		return 0 if ( (! is_addressable32_intel($r3)) && (is_reg8_intel($r3) || is_segreg_intel($r3)
			|| is_reg16_intel($r3) || is_reg64_intel($r3) || is_reg32_intel($r3)
			|| is_reg_mm_intel($r3) || is_reg_fpu_intel($r3)) );
		return 0 if ( (! is_addressable32_intel($r6)) && (is_reg8_intel($r6) || is_segreg_intel($r6)
			|| is_reg16_intel($r6) || is_reg64_intel($r6) || is_reg32_intel($r6)
			|| is_reg_mm_intel($r6) || is_reg_fpu_intel($r6)) );
		return 0 if ( (! is_addressable32_intel($r5)) && (is_reg8_intel($r5) || is_segreg_intel($r5)
			|| is_reg16_intel($r5) || is_reg64_intel($r5) || is_reg32_intel($r5)
			|| is_reg_mm_intel($r5) || is_reg_fpu_intel($r5)) );
		return 0 if ( (! is_addressable32_intel($r8)) && (is_reg8_intel($r8) || is_segreg_intel($r8)
			|| is_reg16_intel($r8) || is_reg64_intel($r8) || is_reg32_intel($r8)
			|| is_reg_mm_intel($r8) || is_reg_fpu_intel($r8)) );
		return 0 if ( is_reg_intel($r6) && is_reg_intel($r5) );
		return 0 if ( is_reg_intel($r3) && $r2 =~ /-/o );
		return 0 if ( (is_reg_intel($r5) || is_reg_intel($r6)) && $r4 =~ /-/o );
		return 0 if ( is_reg_intel($r8) && $r7 =~ /-/o );
		return 0 if ( $r5 =~ /\besp\b/io && $r6 =~ /\b\d+\b/o && $r6 != 1 );
		return 0 if ( $r6 =~ /\besp\b/io && $r5 =~ /\b\d+\b/o && $r5 != 1 );
		return 0 if ( is_reg_intel($r5) && $r6 =~ /\b\d+\b/o && $r6 != 1
			&& $r6 != 2 && $r6 != 4 && $r6 != 8);
		return 0 if ( is_reg_intel($r6) && $r5 =~ /\b\d+\b/o && $r5 != 1
			&& $r5 != 2 && $r5 != 4 && $r5 != 8);
		return 0 if ( is_reg_intel($r3) && (is_reg_intel($r5) || is_reg_intel($r6)) && is_reg_intel($r8) );

		return 1;
	}
	elsif (	$elem =~ /^\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]$/o ) {

		my ($r2, $r3, $r7, $r8, $r4, $r5, $r6) = ($1, $2, $3, $4, $5, $6, $7);

		return 0 if ( is_segreg_intel($r3) || is_segreg_intel($r6) || is_segreg_intel($r5)
			|| is_segreg_intel($r8) );
		return 0 if ( (! is_addressable32_intel($r3)) && (is_reg8_intel($r3) || is_segreg_intel($r3)
			|| is_reg16_intel($r3) || is_reg64_intel($r3) || is_reg32_intel($r3)
			|| is_reg_mm_intel($r3) || is_reg_fpu_intel($r3)) );
		return 0 if ( (! is_addressable32_intel($r6)) && (is_reg8_intel($r6) || is_segreg_intel($r6)
			|| is_reg16_intel($r6) || is_reg64_intel($r6) || is_reg32_intel($r6)
			|| is_reg_mm_intel($r6) || is_reg_fpu_intel($r6)) );
		return 0 if ( (! is_addressable32_intel($r5)) && (is_reg8_intel($r5) || is_segreg_intel($r5)
			|| is_reg16_intel($r5) || is_reg64_intel($r5) || is_reg32_intel($r5)
			|| is_reg_mm_intel($r5) || is_reg_fpu_intel($r5)) );
		return 0 if ( (! is_addressable32_intel($r8)) && (is_reg8_intel($r8) || is_segreg_intel($r8)
			|| is_reg16_intel($r8) || is_reg64_intel($r8) || is_reg32_intel($r8)
			|| is_reg_mm_intel($r8) || is_reg_fpu_intel($r8)) );
		return 0 if ( is_reg_intel($r6) && is_reg_intel($r5) );
		return 0 if ( is_reg_intel($r3) && $r2 =~ /-/o );
		return 0 if ( (is_reg_intel($r5) || is_reg_intel($r6)) && $r4 =~ /-/o );
		return 0 if ( is_reg_intel($r8) && $r7 =~ /-/o );
		return 0 if ( $r5 =~ /\besp\b/io && $r6 =~ /\b\d+\b/o && $r6 != 1 );
		return 0 if ( $r6 =~ /\besp\b/io && $r5 =~ /\b\d+\b/o && $r5 != 1 );
		return 0 if ( is_reg_intel($r5) && $r6 =~ /\b\d+\b/o && $r6 != 1
			&& $r6 != 2 && $r6 != 4 && $r6 != 8);
		return 0 if ( is_reg_intel($r6) && $r5 =~ /\b\d+\b/o && $r5 != 1
			&& $r5 != 2 && $r5 != 4 && $r5 != 8);
		return 0 if ( is_reg_intel($r3) && (is_reg_intel($r5) || is_reg_intel($r6)) && is_reg_intel($r8) );

		return 1;
	}
	elsif (	$elem =~ /^\[\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]$/o ) {

		my ($r4, $r5, $r6, $r2, $r3, $r7, $r8) = ($1, $2, $3, $4, $5, $6, $7);

		return 0 if ( is_segreg_intel($r3) || is_segreg_intel($r6) || is_segreg_intel($r5)
			|| is_segreg_intel($r8) );
		return 0 if ( (! is_addressable32_intel($r3)) && (is_reg8_intel($r3) || is_segreg_intel($r3)
			|| is_reg16_intel($r3) || is_reg64_intel($r3) || is_reg32_intel($r3)
			|| is_reg_mm_intel($r3) || is_reg_fpu_intel($r3)) );
		return 0 if ( (! is_addressable32_intel($r6)) && (is_reg8_intel($r6) || is_segreg_intel($r6)
			|| is_reg16_intel($r6) || is_reg64_intel($r6) || is_reg32_intel($r6)
			|| is_reg_mm_intel($r6) || is_reg_fpu_intel($r6)) );
		return 0 if ( (! is_addressable32_intel($r5)) && (is_reg8_intel($r5) || is_segreg_intel($r5)
			|| is_reg16_intel($r5) || is_reg64_intel($r5) || is_reg32_intel($r5)
			|| is_reg_mm_intel($r5) || is_reg_fpu_intel($r5)) );
		return 0 if ( (! is_addressable32_intel($r8)) && (is_reg8_intel($r8) || is_segreg_intel($r8)
			|| is_reg16_intel($r8) || is_reg64_intel($r8) || is_reg32_intel($r8)
			|| is_reg_mm_intel($r8) || is_reg_fpu_intel($r8)) );
		return 0 if ( is_reg_intel($r6) && is_reg_intel($r5) );
		return 0 if ( is_reg_intel($r3) && $r2 =~ /-/o );
		return 0 if ( (is_reg_intel($r5) || is_reg_intel($r6)) && $r4 =~ /-/o );
		return 0 if ( is_reg_intel($r8) && $r7 =~ /-/o );
		return 0 if ( $r5 =~ /\besp\b/io && $r6 =~ /\b\d+\b/o && $r6 != 1 );
		return 0 if ( $r6 =~ /\besp\b/io && $r5 =~ /\b\d+\b/o && $r5 != 1 );
		return 0 if ( is_reg_intel($r5) && $r6 =~ /\b\d+\b/o && $r6 != 1
			&& $r6 != 2 && $r6 != 4 && $r6 != 8);
		return 0 if ( is_reg_intel($r6) && $r5 =~ /\b\d+\b/o && $r5 != 1
			&& $r5 != 2 && $r5 != 4 && $r5 != 8);
		return 0 if ( is_reg_intel($r3) && (is_reg_intel($r5) || is_reg_intel($r6)) && is_reg_intel($r8) );

		return 1;
	}
	elsif (	$elem =~ /^\[\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]$/o ) {

		my ($r4, $r5, $r6, $r2, $r3) = ($1, $2, $3, $4, $5, $6);

		return 0 if ( is_segreg_intel($r3) || is_segreg_intel($r6) || is_segreg_intel($r5) );
		return 0 if ( (! is_addressable32_intel($r3)) && (is_reg8_intel($r3) || is_segreg_intel($r3)
			|| is_reg16_intel($r3) || is_reg64_intel($r3) || is_reg32_intel($r3)
			|| is_reg_mm_intel($r3) || is_reg_fpu_intel($r3)) );
		return 0 if ( (! is_addressable32_intel($r6)) && (is_reg8_intel($r6) || is_segreg_intel($r6)
			|| is_reg16_intel($r6) || is_reg64_intel($r6) || is_reg32_intel($r6)
			|| is_reg_mm_intel($r6) || is_reg_fpu_intel($r6)) );
		return 0 if ( (! is_addressable32_intel($r5)) && (is_reg8_intel($r5) || is_segreg_intel($r5)
			|| is_reg16_intel($r5) || is_reg64_intel($r5) || is_reg32_intel($r5)
			|| is_reg_mm_intel($r5) || is_reg_fpu_intel($r5)) );
		return 0 if ( is_reg_intel($r6) && is_reg_intel($r5) );
		return 0 if ( is_reg_intel($r3) && $r2 =~ /-/o );
		return 0 if ( (is_reg_intel($r5) || is_reg_intel($r6)) && $r4 =~ /-/o );
		return 0 if ( $r5 =~ /\besp\b/io && $r6 =~ /\b\d+\b/o && $r6 != 1 );
		return 0 if ( $r6 =~ /\besp\b/io && $r5 =~ /\b\d+\b/o && $r5 != 1 );
		return 0 if ( is_reg_intel($r5) && $r6 =~ /\b\d+\b/o && $r6 != 1
			&& $r6 != 2 && $r6 != 4 && $r6 != 8);
		return 0 if ( is_reg_intel($r6) && $r5 =~ /\b\d+\b/o && $r5 != 1
			&& $r5 != 2 && $r5 != 4 && $r5 != 8);

		return 1;
	}
	elsif (	$elem =~ /^\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]$/o ) {

		my ($r2, $r3, $r4, $r5, $r7, $r8) = ($1, $2, $3, $4, $5, $6);

		return 0 if ( is_segreg_intel($r3) || is_segreg_intel($r5) || is_segreg_intel($r8) );
		return 0 if ( (! is_addressable32_intel($r3)) && (is_reg8_intel($r3) || is_segreg_intel($r3)
			|| is_reg16_intel($r3) || is_reg64_intel($r3) || is_reg32_intel($r3)
			|| is_reg_mm_intel($r3) || is_reg_fpu_intel($r3)) );
		return 0 if ( (! is_addressable32_intel($r5)) && (is_reg8_intel($r5) || is_segreg_intel($r5)
			|| is_reg16_intel($r5) || is_reg64_intel($r5) || is_reg32_intel($r5)
			|| is_reg_mm_intel($r5) || is_reg_fpu_intel($r5)) );
		return 0 if ( (! is_addressable32_intel($r8)) && (is_reg8_intel($r8) || is_segreg_intel($r8)
			|| is_reg16_intel($r8) || is_reg64_intel($r8) || is_reg32_intel($r8)
			|| is_reg_mm_intel($r8) || is_reg_fpu_intel($r8)) );
		return 0 if ( is_reg_intel($r3) && $r2 =~ /-/o );
		return 0 if ( is_reg_intel($r5) && $r4 =~ /-/o );
		return 0 if ( is_reg_intel($r8) && $r7 =~ /-/o );
		return 0 if ( is_reg_intel($r3) && is_reg_intel($r5) && is_reg_intel($r8) );

		return 1;
	}
	elsif (	$elem =~ /^\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]$/o ) {

		my ($r2, $r3, $r4, $r5, $r6) = ($1, $2, $3, $4, $5);

		return 0 if ( is_segreg_intel($r3) || is_segreg_intel($r6) || is_segreg_intel($r5) );
		return 0 if ( (! is_addressable32_intel($r3)) && (is_reg8_intel($r3) || is_segreg_intel($r3)
			|| is_reg16_intel($r3) || is_reg64_intel($r3) || is_reg32_intel($r3)
			|| is_reg_mm_intel($r3) || is_reg_fpu_intel($r3)) );
		return 0 if ( (! is_addressable32_intel($r6)) && (is_reg8_intel($r6) || is_segreg_intel($r6)
			|| is_reg16_intel($r6) || is_reg64_intel($r6) || is_reg32_intel($r6)
			|| is_reg_mm_intel($r6) || is_reg_fpu_intel($r6)) );
		return 0 if ( (! is_addressable32_intel($r5)) && (is_reg8_intel($r5) || is_segreg_intel($r5)
			|| is_reg16_intel($r5) || is_reg64_intel($r5) || is_reg32_intel($r5)
			|| is_reg_mm_intel($r5) || is_reg_fpu_intel($r5)) );
		return 0 if ( is_reg_intel($r6) && is_reg_intel($r5) );
		return 0 if ( is_reg_intel($r3) && $r2 =~ /-/o );
		return 0 if ( (is_reg_intel($r5) || is_reg_intel($r6)) && $r4 =~ /-/o );
		return 0 if ( $r5 =~ /\besp\b/io && $r6 =~ /\b\d+\b/o && $r6 != 1 );
		return 0 if ( $r6 =~ /\besp\b/io && $r5 =~ /\b\d+\b/o && $r5 != 1 );
		return 0 if ( is_reg_intel($r5) && $r6 =~ /\b\d+\b/o && $r6 != 1
			&& $r6 != 2 && $r6 != 4 && $r6 != 8);
		return 0 if ( is_reg_intel($r6) && $r5 =~ /\b\d+\b/o && $r5 != 1
			&& $r5 != 2 && $r5 != 4 && $r5 != 8);

		return 1;
	}
	elsif (	$elem =~ /^\[\s*([\+\-\(\)]*)\s*(\w+)\s*\]$/o ) {

		my ($r2, $r3) = ($1, $2);

		return 0 if ( is_segreg_intel($r3) );
		return 0 if ( (! is_addressable32_intel($r3)) && (is_reg8_intel($r3) || is_segreg_intel($r3)
			|| is_reg16_intel($r3) || is_reg64_intel($r3) || is_reg32_intel($r3)
			|| is_reg_mm_intel($r3) || is_reg_fpu_intel($r3)) );
		return 0 if ( is_reg_intel($r3) && $r2 =~ /-/o );

		return 1;
	}
	elsif (	$elem =~ /^\[\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]$/o ) {

		my ($r2, $r3, $r4) = ($1, $2, $3);

		return 0 if ( is_segreg_intel($r3) || is_segreg_intel($r4) );
		return 0 if ( (! is_addressable32_intel($r3)) && (is_reg8_intel($r3) || is_segreg_intel($r3)
			|| is_reg16_intel($r3) || is_reg64_intel($r3) || is_reg32_intel($r3)
			|| is_reg_mm_intel($r3) || is_reg_fpu_intel($r3)) );
		return 0 if ( (! is_addressable32_intel($r4)) && (is_reg8_intel($r4) || is_segreg_intel($r4)
			|| is_reg16_intel($r4) || is_reg64_intel($r4) || is_reg32_intel($r4)
			|| is_reg_mm_intel($r4) || is_reg_fpu_intel($r4)) );
		return 0 if ( is_reg_intel($r3) && is_reg_intel($r4) );
		return 0 if ( is_reg_intel($r3) && $r2 =~ /-/o );
		return 0 if ( (is_reg_intel($r3) || is_reg_intel($r4)) && $r2 =~ /-/o );
		return 0 if ( $r3 =~ /\besp\b/io && $r4 =~ /\b\d+\b/o && $r4 != 1 );
		return 0 if ( $r4 =~ /\besp\b/io && $r3 =~ /\b\d+\b/o && $r3 != 1 );
		return 0 if ( is_reg_intel($r3) && $r4 =~ /\b\d+\b/o && $r4 != 1
			&& $r4 != 2 && $r4 != 4 && $r4 != 8);
		return 0 if ( is_reg_intel($r4) && $r3 =~ /\b\d+\b/o && $r3 != 1
			&& $r3 != 2 && $r3 != 4 && $r3 != 8);

		return 1;
	}
	elsif (	$elem =~ /^\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]*)\s*(\w+)\s*\]$/o ) {

		my ($r2, $r3, $r4, $r5) = ($1, $2, $3, $4);

		return 0 if ( is_segreg_intel($r3) || is_segreg_intel($r5) );
		return 0 if ( (! is_addressable32_intel($r3)) && (is_reg8_intel($r3) || is_segreg_intel($r3)
			|| is_reg16_intel($r3) || is_reg64_intel($r3) || is_reg32_intel($r3)
			|| is_reg_mm_intel($r3) || is_reg_fpu_intel($r3)) );
		return 0 if ( (! is_addressable32_intel($r5)) && (is_reg8_intel($r5) || is_segreg_intel($r5)
			|| is_reg16_intel($r5) || is_reg64_intel($r5) || is_reg32_intel($r5)
			|| is_reg_mm_intel($r5) || is_reg_fpu_intel($r5)) );
		return 0 if ( is_reg_intel($r3) && $r2 =~ /-/o );
		return 0 if ( is_reg_intel($r5) && $r4 =~ /-/o );

		return 1;
	}
	return 0;
}

=head2 is_valid_32bit_addr_att

 Checks if the given string parameter (must contain the parentheses)
  is a valid x86 32-bit addressing mode in AT&T syntax.
 Returns 1 if yes.

=cut

sub is_valid_32bit_addr_att($) {

	my $elem = shift;
	if ( $elem =~ /^([%\w]+):\s*\(\s*([+-]*)\s*([%\w]+)\s*\)$/o ) {

		my ($r1, $r2, $sign) = ($1, $3, $2);
		return 0 if (! is_segreg_att ($r1)) || is_segreg_att ($r2);
		return 0 if is_reg_att($r2) && ! is_addressable32_att ($r2);
		return 0 if is_reg32_att($r2) && $sign =~ /-/o;
		return 1;
	}
	elsif ( $elem =~ /^([%\w]+):\s*\(\s*([%\w]+)\s*,\s*([%\w]+)\s*\)$/o ) {

		my ($r1, $r2, $r3) = ($1, $2, $3);
		return 0 if (! is_segreg_att ($r1)) || is_segreg_att ($r2) || is_segreg_att ($r3);
		return 0 if (! is_reg_att($r2)) || (! is_reg_att($r3));
		return 0 if is_reg_att($r2) && ! is_addressable32_att ($r2);
		return 0 if is_reg_att($r3) && ! is_addressable32_att ($r3);
		return 1;
	}
	elsif ( $elem =~ /^([%\w]+):\s*\(\s*([%\w]+)\s*,\s*([%\w]+)\s*,\s*(\d+)\s*\)$/o ) {

		my ($r1, $r2, $r3, $scale) = ($1, $2, $3, $4);
		return 0 if (! is_segreg_att ($r1)) || is_segreg_att ($r2) || is_segreg_att ($r3);
		return 0 if (! is_reg_att($r2)) || (! is_reg_att($r3));
		return 0 if is_reg_att($r2) && ! is_addressable32_att ($r2);
		return 0 if is_reg_att($r3) && ! is_addressable32_att ($r3);
		return 0 if $r3 =~ /^%esp$/io;
		return 0 if $scale != 1 && $scale != 2 && $scale != 4 && $scale != 8;
		return 1;
	}
	elsif ( $elem =~ /^([%\w]+):\s*\(\s*,\s*([%\w]+)\s*,\s*(\d+)\s*\)$/o ) {

		my ($r1, $r3, $scale) = ($1, $2, $3);
		return 0 if (! is_segreg_att ($r1)) || is_segreg_att ($r3);
		return 0 if ! is_reg_att($r3);
		return 0 if is_reg_att($r3) && ! is_addressable32_att ($r3);
		return 0 if $r3 =~ /^%esp$/io;
		return 0 if $scale != 1 && $scale != 2 && $scale != 4 && $scale != 8;
		return 1;
	}
	elsif ( $elem =~ /^([%\w]+):\s*[+-]*\s*([%\w]+)\s*\(\s*([+-]*)\s*([%\w]+)\s*\)$/o ) {

		my ($r1, $r2, $var, $sign) = ($1, $4, $2, $3);
		return 0 if (! is_segreg_att ($r1)) || is_segreg_att ($r2);
		return 0 if is_reg_att($r2) && ! is_addressable32_att ($r2);
		return 0 if is_reg32_att($r2) && $sign =~ /-/o;
		return 0 if is_reg_att($var);
		return 1;
	}
	elsif ( $elem =~ /^([%\w]+):\s*[+-]*\s*([%\w]+)\s*\(\s*([%\w]+)\s*,\s*([%\w]+)\s*\)$/o ) {

		my ($r1, $r2, $r3, $var) = ($1, $3, $4, $2);
		return 0 if (! is_segreg_att ($r1)) || is_segreg_att ($r2) || is_segreg_att ($r3);
		return 0 if (! is_reg32_att($r2)) || (! is_reg32_att($r3));
		return 0 if is_reg_att($r2) && ! is_addressable32_att ($r2);
		return 0 if is_reg_att($r3) && ! is_addressable32_att ($r3);
		return 0 if is_reg_att($var);
		return 1;
	}
	elsif ( $elem =~ /^([%\w]+):\s*[+-]*\s*([%\w]+)\s*\(\s*([%\w]+)\s*,\s*([%\w]+)\s*,\s*(\d+)\s*\)$/o ) {

		my ($r1, $r2, $r3, $var, $scale) = ($1, $3, $4, $2, $5);
		return 0 if (! is_segreg_att ($r1)) || is_segreg_att ($r2) || is_segreg_att ($r3);
		return 0 if (! is_reg32_att($r2)) || (! is_reg32_att($r3));
		return 0 if is_reg_att($r2) && ! is_addressable32_att ($r2);
		return 0 if is_reg_att($r3) && ! is_addressable32_att ($r3);
		return 0 if is_reg_att($var);
		return 0 if $r3 =~ /^%esp$/io;
		return 0 if $scale != 1 && $scale != 2 && $scale != 4 && $scale != 8;
		return 1;
	}
	elsif ( $elem =~ /^([%\w]+):\s*[+-]*\s*([%\w]+)\s*\(\s*,\s*([%\w]+)\s*,\s*(\d+)\s*\)$/o ) {

		my ($r1, $r3, $var, $scale) = ($1, $3, $2, $4);
		return 0 if (! is_segreg_att ($r1)) || is_segreg_att ($r3);
		return 0 if ! is_reg32_att($r3);
		return 0 if is_reg_att($r3) && ! is_addressable32_att ($r3);
		return 0 if is_reg_att($var);
		return 0 if $r3 =~ /^%esp$/io;
		return 0 if $scale != 1 && $scale != 2 && $scale != 4 && $scale != 8;
		return 1;
	}
	elsif ( $elem =~ /^([%\w]+):\s*[+-]*\s*([%\w]+)\s*\(\s*,\s*1\s*\)$/o ) {

		# special form: varname(1,)
		my ($r1, $var) = ($1, $2);
		return 0 if is_reg_att($var) || ! is_segreg_att ($r1);
		return 1;
	}
	elsif ( $elem =~ /^\(\s*([+-]*)\s*([%\w]+)\s*\)$/o ) {

		my ($r2, $sign) = ($2, $1);
		return 0 if is_segreg_att ($r2);
		return 0 if is_reg_att($r2) && ! is_addressable32_att ($r2);
		return 0 if is_reg32_att($r2) && $sign =~ /-/o;
		return 1;
	}
	elsif ( $elem =~ /^\(\s*([%\w]+)\s*,\s*([%\w]+)\s*\)$/o ) {

		my ($r2, $r3) = ($1, $2);
		return 0 if is_segreg_att ($r2) || is_segreg_att ($r3);
		return 0 if is_reg_att($r2) && ! is_addressable32_att ($r2);
		return 0 if is_reg_att($r3) && ! is_addressable32_att ($r3);
		return 0 if (! is_reg_att($r2)) || (! is_reg32_att($r3));
		return 1;
	}
	elsif ( $elem =~ /^\(\s*([%\w]+)\s*,\s*([%\w]+)\s*,\s*(\d+)\s*\)$/o ) {

		my ($r2, $r3, $scale) = ($1, $2, $3);
		return 0 if is_segreg_att ($r2) || is_segreg_att ($r3);
		return 0 if (! is_reg32_att($r2)) || (! is_reg32_att($r3));
		return 0 if is_reg_att($r2) && ! is_addressable32_att ($r2);
		return 0 if is_reg_att($r3) && ! is_addressable32_att ($r3);
		return 0 if $r3 =~ /^%esp$/io;
		return 0 if $scale != 1 && $scale != 2 && $scale != 4 && $scale != 8;
		return 1;
	}
	elsif ( $elem =~ /^\(\s*,\s*([%\w]+)\s*,\s*(\d+)\s*\)$/o ) {

		my ($r3, $scale) = ($1, $2);
		return 0 if is_segreg_att ($r3);
		return 0 if ! is_reg32_att($r3);
		return 0 if is_reg_att($r3) && ! is_addressable32_att ($r3);
		return 0 if $r3 =~ /^%esp$/io;
		return 0 if $scale != 1 && $scale != 2 && $scale != 4 && $scale != 8;
		return 1;
	}
	elsif ( $elem =~ /^[+-]*\s*([%\w]+)\s*\(\s*([+-]*)\s*([%\w]+)\s*\)$/o ) {

		my ($r2, $var, $sign) = ($3, $1, $2);
		return 0 if is_segreg_att ($r2);
		return 0 if is_reg_att($r2) && ! is_addressable32_att ($r2);
		return 0 if is_reg32_att($r2) && $sign =~ /-/o;
		return 0 if is_reg_att($var);
		return 1;
	}
	elsif ( $elem =~ /^[+-]*\s*([%\w]+)\s*\(\s*([%\w]+)\s*,\s*([%\w]+)\s*\)$/o ) {

		my ($r2, $r3, $var) = ($2, $3, $1);
		return 0 if is_segreg_att ($r2) || is_segreg_att ($r3);
		return 0 if (! is_reg_att($r2)) || (! is_reg32_att($r3));
		return 0 if is_reg_att($r2) && ! is_addressable32_att ($r2);
		return 0 if is_reg_att($r3) && ! is_addressable32_att ($r3);
		return 0 if is_reg_att($var);
		return 1;
	}
	elsif ( $elem =~ /^[+-]*\s*([%\w]+)\s*\(\s*([%\w]+)\s*,\s*([%\w]+)\s*,\s*(\d+)\s*\)$/o ) {

		my ($r2, $r3, $scale, $var) = ($2, $3, $4, $1);
		return 0 if is_segreg_att ($r2) || is_segreg_att ($r3);
		return 0 if (! is_reg32_att($r2)) || (! is_reg32_att($r3));
		return 0 if is_reg_att($r2) && ! is_addressable32_att ($r2);
		return 0 if is_reg_att($r3) && ! is_addressable32_att ($r3);
		return 0 if $r3 =~ /^%esp$/io;
		return 0 if $scale != 1 && $scale != 2 && $scale != 4 && $scale != 8;
		return 0 if is_reg_att($var);
		return 1;
	}
	elsif ( $elem =~ /^[+-]*\s*([%\w]+)\s*\(\s*,\s*([%\w]+)\s*,\s*(\d+)\s*\)$/o ) {

		my ($r3, $scale, $var) = ($2, $3, $1);
		return 0 if is_segreg_att ($r3);
		return 0 if ! is_reg32_att($r3);
		return 0 if is_reg_att($r3) && ! is_addressable32_att ($r3);
		return 0 if $r3 =~ /^%esp$/io;
		return 0 if $scale != 1 && $scale != 2 && $scale != 4 && $scale != 8;
		return 0 if is_reg_att($var);
		return 1;
	}
	elsif ( $elem =~ /^[+-]*\s*([%\w]+)\s*\(\s*,\s*1\s*\)$/o ) {

		# special form: varname(1,)
		my $var = $1;
		return 0 if is_reg_att($var);
		return 1;
	}
	return 0;
}

=head2 is_valid_32bit_addr

 Checks if the given string parameter (must contain the parentheses)
  is a valid x86 32-bit addressing mode in AT&T or Intel syntax.
 Returns 1 if yes.

=cut

sub is_valid_32bit_addr($) {

	my $elem = shift;
	return    is_valid_32bit_addr_intel($elem)
		| is_valid_32bit_addr_att($elem);
}

=head2 is_valid_64bit_addr_intel

 Checks if the given string parameter (must contain the square braces)
  is a valid x86 64-bit addressing mode in Intel syntax.
 Returns 1 if yes.

=cut

sub is_valid_64bit_addr_intel($) {

	my $elem = shift;
	# [seg:base+index*scale+disp]
	if (	$elem =~ /^\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]$/o
		|| $elem =~ /^(\w+)\s*:\s*\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]$/o) {

		my ($r1, $r2, $r3, $r4, $r5, $r6, $r7, $r8) = ($1, $2, $3, $4, $5, $6, $7, $8);

		return 0 if ( is_segreg_intel($r3) || is_segreg_intel($r6) || is_segreg_intel($r5)
			|| is_segreg_intel($r8) || ! is_segreg_intel($r1) );
		return 0 if ( (! is_reg64_intel($r3) && ! is_r32_in64_intel($r3) && ! is_addressable32_intel($r3))
			&& (is_reg8_intel($r3) || is_segreg_intel($r3)
			|| is_reg16_intel($r3) || is_reg32_intel($r3)
			|| is_reg_mm_intel($r3) || is_reg_fpu_intel($r3)) );
		return 0 if ( (! is_reg64_intel($r6) && ! is_r32_in64_intel($r6) && ! is_addressable32_intel($r6))
			&& (is_reg8_intel($r6) || is_segreg_intel($r6)
			|| is_reg16_intel($r6) || is_reg32_intel($r6)
			|| is_reg_mm_intel($r6) || is_reg_fpu_intel($r6)) );
		return 0 if ( (! is_reg64_intel($r5) && ! is_r32_in64_intel($r5) && ! is_addressable32_intel($r5))
			&& (is_reg8_intel($r5) || is_segreg_intel($r5)
			|| is_reg16_intel($r5) || is_reg32_intel($r5)
			|| is_reg_mm_intel($r5) || is_reg_fpu_intel($r5)) );
		return 0 if ( (! is_reg64_intel($r8) && ! is_r32_in64_intel($r8) && ! is_addressable32_intel($r8))
			&& (is_reg8_intel($r8) || is_segreg_intel($r8)
			|| is_reg16_intel($r8) || is_reg32_intel($r8)
			|| is_reg_mm_intel($r8) || is_reg_fpu_intel($r8)) );
		my $was64 = is_reg64_intel($r3) + is_reg64_intel($r5) + is_reg64_intel($r6) + is_reg64_intel($r8);
		my $nregs = is_reg_intel($r3) + is_reg_intel($r5) + is_reg_intel($r6) + is_reg_intel($r8);
		return 0 if ( $was64 != 0 && $was64 != $nregs );
		return 0 if ( is_reg_intel($r6) && is_reg_intel($r5) );
		return 0 if ( is_reg_intel($r3) && $r2 =~ /-/o );
		return 0 if ( (is_reg_intel($r5) || is_reg_intel($r6)) && $r4 =~ /-/o );
		return 0 if ( is_reg_intel($r8) && $r7 =~ /-/o );
		return 0 if ( ($r5 =~ /\brsp\b/io || $r5 =~ /\brip\b/io) && $r6 =~ /\b\d+\b/o && $r6 != 1 );
		return 0 if ( ($r6 =~ /\brsp\b/io || $r6 =~ /\brip\b/io) && $r5 =~ /\b\d+\b/o && $r5 != 1 );
		return 0 if ( is_reg_intel($r5) && $r6 =~ /\b\d+\b/o && $r6 != 1
			&& $r6 != 2 && $r6 != 4 && $r6 != 8);
		return 0 if ( is_reg_intel($r6) && $r5 =~ /\b\d+\b/o && $r5 != 1
			&& $r5 != 2 && $r5 != 4 && $r5 != 8);
		return 0 if ( is_reg_intel($r3) && (is_reg_intel($r5) || is_reg_intel($r6)) && is_reg_intel($r8) );

		return 1;
	}
	elsif (	$elem =~ /^\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]$/o
		|| $elem =~ /^(\w+)\s*:\s*\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]$/o) {

		my ($r1, $r2, $r3, $r7, $r8, $r4, $r5, $r6) = ($1, $2, $3, $4, $5, $6, $7, $8);

		return 0 if ( is_segreg_intel($r3) || is_segreg_intel($r6) || is_segreg_intel($r5)
			|| is_segreg_intel($r8) || ! is_segreg_intel($r1) );
		return 0 if ( (! is_reg64_intel($r3) && ! is_r32_in64_intel($r3) && ! is_addressable32_intel($r3))
			&& (is_reg8_intel($r3) || is_segreg_intel($r3)
			|| is_reg16_intel($r3) || is_reg32_intel($r3)
			|| is_reg_mm_intel($r3) || is_reg_fpu_intel($r3)) );
		return 0 if ( (! is_reg64_intel($r6) && ! is_r32_in64_intel($r6) && ! is_addressable32_intel($r6))
			&& (is_reg8_intel($r6) || is_segreg_intel($r6)
			|| is_reg16_intel($r6) || is_reg32_intel($r6)
			|| is_reg_mm_intel($r6) || is_reg_fpu_intel($r6)) );
		return 0 if ( (! is_reg64_intel($r5) && ! is_r32_in64_intel($r5) && ! is_addressable32_intel($r5))
			&& (is_reg8_intel($r5) || is_segreg_intel($r5)
			|| is_reg16_intel($r5) || is_reg32_intel($r5)
			|| is_reg_mm_intel($r5) || is_reg_fpu_intel($r5)) );
		return 0 if ( (! is_reg64_intel($r8) && ! is_r32_in64_intel($r8) && ! is_addressable32_intel($r8))
			&& (is_reg8_intel($r8) || is_segreg_intel($r8)
			|| is_reg16_intel($r8) || is_reg32_intel($r8)
			|| is_reg_mm_intel($r8) || is_reg_fpu_intel($r8)) );
		my $was64 = is_reg64_intel($r3) + is_reg64_intel($r5) + is_reg64_intel($r6) + is_reg64_intel($r8);
		my $nregs = is_reg_intel($r3) + is_reg_intel($r5) + is_reg_intel($r6) + is_reg_intel($r8);
		return 0 if ( $was64 != 0 && $was64 != $nregs );
		return 0 if ( is_reg_intel($r6) && is_reg_intel($r5) );
		return 0 if ( is_reg_intel($r3) && $r2 =~ /-/o );
		return 0 if ( (is_reg_intel($r5) || is_reg_intel($r6)) && $r4 =~ /-/o );
		return 0 if ( is_reg_intel($r8) && $r7 =~ /-/o );
		return 0 if ( ($r5 =~ /\brsp\b/io || $r5 =~ /\brip\b/io) && $r6 =~ /\b\d+\b/o && $r6 != 1 );
		return 0 if ( ($r6 =~ /\brsp\b/io || $r6 =~ /\brip\b/io) && $r5 =~ /\b\d+\b/o && $r5 != 1 );
		return 0 if ( is_reg_intel($r5) && $r6 =~ /\b\d+\b/o && $r6 != 1
			&& $r6 != 2 && $r6 != 4 && $r6 != 8);
		return 0 if ( is_reg_intel($r6) && $r5 =~ /\b\d+\b/o && $r5 != 1
			&& $r5 != 2 && $r5 != 4 && $r5 != 8);
		return 0 if ( is_reg_intel($r3) && (is_reg_intel($r5) || is_reg_intel($r6)) && is_reg_intel($r8) );

		return 1;
	}
	elsif (	$elem =~ /^\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]$/o
		|| $elem =~ /^(\w+)\s*:\s*\[\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]$/o) {

		my ($r1, $r4, $r5, $r6, $r2, $r3, $r7, $r8) = ($1, $2, $3, $4, $5, $6, $7, $8);

		return 0 if ( is_segreg_intel($r3) || is_segreg_intel($r6) || is_segreg_intel($r5)
			|| is_segreg_intel($r8) || ! is_segreg_intel($r1) );
		return 0 if ( (! is_reg64_intel($r3) && ! is_r32_in64_intel($r3) && ! is_addressable32_intel($r3))
			&& (is_reg8_intel($r3) || is_segreg_intel($r3)
			|| is_reg16_intel($r3) || is_reg32_intel($r3)
			|| is_reg_mm_intel($r3) || is_reg_fpu_intel($r3)) );
		return 0 if ( (! is_reg64_intel($r6) && ! is_r32_in64_intel($r6) && ! is_addressable32_intel($r6))
			&& (is_reg8_intel($r6) || is_segreg_intel($r6)
			|| is_reg16_intel($r6) || is_reg32_intel($r6)
			|| is_reg_mm_intel($r6) || is_reg_fpu_intel($r6)) );
		return 0 if ( (! is_reg64_intel($r5) && ! is_r32_in64_intel($r5) && ! is_addressable32_intel($r5))
			&& (is_reg8_intel($r5) || is_segreg_intel($r5)
			|| is_reg16_intel($r5) || is_reg32_intel($r5)
			|| is_reg_mm_intel($r5) || is_reg_fpu_intel($r5)) );
		return 0 if ( (! is_reg64_intel($r8) && ! is_r32_in64_intel($r8) && ! is_addressable32_intel($r8))
			&& (is_reg8_intel($r8) || is_segreg_intel($r8)
			|| is_reg16_intel($r8) || is_reg32_intel($r8)
			|| is_reg_mm_intel($r8) || is_reg_fpu_intel($r8)) );
		my $was64 = is_reg64_intel($r3) + is_reg64_intel($r5) + is_reg64_intel($r6) + is_reg64_intel($r8);
		my $nregs = is_reg_intel($r3) + is_reg_intel($r5) + is_reg_intel($r6) + is_reg_intel($r8);
		return 0 if ( $was64 != 0 && $was64 != $nregs );
		return 0 if ( is_reg_intel($r6) && is_reg_intel($r5) );
		return 0 if ( is_reg_intel($r3) && $r2 =~ /-/o );
		return 0 if ( (is_reg_intel($r5) || is_reg_intel($r6)) && $r4 =~ /-/o );
		return 0 if ( is_reg_intel($r8) && $r7 =~ /-/o );
		return 0 if ( ($r5 =~ /\brsp\b/io || $r5 =~ /\brip\b/io) && $r6 =~ /\b\d+\b/o && $r6 != 1 );
		return 0 if ( ($r6 =~ /\brsp\b/io || $r6 =~ /\brip\b/io) && $r5 =~ /\b\d+\b/o && $r5 != 1 );
		return 0 if ( is_reg_intel($r5) && $r6 =~ /\b\d+\b/o && $r6 != 1
			&& $r6 != 2 && $r6 != 4 && $r6 != 8);
		return 0 if ( is_reg_intel($r6) && $r5 =~ /\b\d+\b/o && $r5 != 1
			&& $r5 != 2 && $r5 != 4 && $r5 != 8);
		return 0 if ( is_reg_intel($r3) && (is_reg_intel($r5) || is_reg_intel($r6)) && is_reg_intel($r8) );

		return 1;
	}
	elsif (	$elem =~ /^\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]$/o
		|| $elem =~ /^(\w+)\s*:\s*\[\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]$/o) {

		my ($r1, $r4, $r5, $r6, $r2, $r3) = ($1, $2, $3, $4, $5, $6);

		return 0 if ( is_segreg_intel($r3) || is_segreg_intel($r6) || is_segreg_intel($r5)
			|| ! is_segreg_intel($r1) );
		return 0 if ( (! is_reg64_intel($r3) && ! is_r32_in64_intel($r3) && ! is_addressable32_intel($r3))
			&& (is_reg8_intel($r3) || is_segreg_intel($r3)
			|| is_reg16_intel($r3) || is_reg32_intel($r3)
			|| is_reg_mm_intel($r3) || is_reg_fpu_intel($r3)) );
		return 0 if ( (! is_reg64_intel($r6) && ! is_r32_in64_intel($r6) && ! is_addressable32_intel($r6))
			&& (is_reg8_intel($r6) || is_segreg_intel($r6)
			|| is_reg16_intel($r6) || is_reg32_intel($r6)
			|| is_reg_mm_intel($r6) || is_reg_fpu_intel($r6)) );
		return 0 if ( (! is_reg64_intel($r5) && ! is_r32_in64_intel($r5) && ! is_addressable32_intel($r5))
			&& (is_reg8_intel($r5) || is_segreg_intel($r5)
			|| is_reg16_intel($r5) || is_reg32_intel($r5)
			|| is_reg_mm_intel($r5) || is_reg_fpu_intel($r5)) );
		my $was64 = is_reg64_intel($r3) + is_reg64_intel($r5) + is_reg64_intel($r6);
		my $nregs = is_reg_intel($r3) + is_reg_intel($r5) + is_reg_intel($r6);
		return 0 if ( $was64 != 0 && $was64 != $nregs );
		return 0 if ( is_reg_intel($r6) && is_reg_intel($r5) );
		return 0 if ( is_reg_intel($r3) && $r2 =~ /-/o );
		return 0 if ( (is_reg_intel($r5) || is_reg_intel($r6)) && $r4 =~ /-/o );
		return 0 if ( ($r5 =~ /\brsp\b/io || $r5 =~ /\brip\b/io) && $r6 =~ /\b\d+\b/o && $r6 != 1 );
		return 0 if ( ($r6 =~ /\brsp\b/io || $r6 =~ /\brip\b/io) && $r5 =~ /\b\d+\b/o && $r5 != 1 );
		return 0 if ( is_reg_intel($r5) && $r6 =~ /\b\d+\b/o && $r6 != 1
			&& $r6 != 2 && $r6 != 4 && $r6 != 8);
		return 0 if ( is_reg_intel($r6) && $r5 =~ /\b\d+\b/o && $r5 != 1
			&& $r5 != 2 && $r5 != 4 && $r5 != 8);

		return 1;
	}
	elsif (	$elem =~ /^\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]$/o
		|| $elem =~ /^(\w+)\s*:\s*\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]$/o) {

		my ($r1, $r2, $r3, $r4, $r5, $r7, $r8) = ($1, $2, $3, $4, $5, $6, $7);

		return 0 if ( is_segreg_intel($r3) || is_segreg_intel($r5)
			|| is_segreg_intel($r8) || ! is_segreg_intel($r1) );
		return 0 if ( (! is_reg64_intel($r3) && ! is_r32_in64_intel($r3) && ! is_addressable32_intel($r3))
			&& (is_reg8_intel($r3) || is_segreg_intel($r3)
			|| is_reg16_intel($r3) || is_reg32_intel($r3)
			|| is_reg_mm_intel($r3) || is_reg_fpu_intel($r3)) );
		return 0 if ( (! is_reg64_intel($r5) && ! is_r32_in64_intel($r5) && ! is_addressable32_intel($r5))
			&& (is_reg8_intel($r5) || is_segreg_intel($r5)
			|| is_reg16_intel($r5) || is_reg32_intel($r5)
			|| is_reg_mm_intel($r5) || is_reg_fpu_intel($r5)) );
		return 0 if ( (! is_reg64_intel($r8) && ! is_r32_in64_intel($r8) && ! is_addressable32_intel($r8))
			&& (is_reg8_intel($r8) || is_segreg_intel($r8)
			|| is_reg16_intel($r8) || is_reg32_intel($r8)
			|| is_reg_mm_intel($r8) || is_reg_fpu_intel($r8)) );
		my $was64 = is_reg64_intel($r3) + is_reg64_intel($r5) + is_reg64_intel($r8);
		my $nregs = is_reg_intel($r3) + is_reg_intel($r5) + is_reg_intel($r8);
		return 0 if ( $was64 != 0 && $was64 != $nregs );
		return 0 if ( is_reg_intel($r3) && $r2 =~ /-/o );
		return 0 if ( is_reg_intel($r5) && $r4 =~ /-/o );
		return 0 if ( is_reg_intel($r8) && $r7 =~ /-/o );
		return 0 if ( is_reg_intel($r3) && is_reg_intel($r5) && is_reg_intel($r8) );

		return 1;
	}
	elsif (	$elem =~ /^\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]$/o
		|| $elem =~ /^(\w+)\s*:\s*\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]$/o) {

		my ($r1, $r2, $r3, $r4, $r5, $r6) = ($1, $2, $3, $4, $5, $6);

		return 0 if ( is_segreg_intel($r3) || is_segreg_intel($r6) || is_segreg_intel($r5)
			|| ! is_segreg_intel($r1) );
		return 0 if ( (! is_reg64_intel($r3) && ! is_r32_in64_intel($r3) && ! is_addressable32_intel($r3))
			&& (is_reg8_intel($r3) || is_segreg_intel($r3)
			|| is_reg16_intel($r3) || is_reg32_intel($r3)
			|| is_reg_mm_intel($r3) || is_reg_fpu_intel($r3)) );
		return 0 if ( (! is_reg64_intel($r6) && ! is_r32_in64_intel($r6) && ! is_addressable32_intel($r6))
			&& (is_reg8_intel($r6) || is_segreg_intel($r6)
			|| is_reg16_intel($r6) || is_reg32_intel($r6)
			|| is_reg_mm_intel($r6) || is_reg_fpu_intel($r6)) );
		return 0 if ( (! is_reg64_intel($r5) && ! is_r32_in64_intel($r5) && ! is_addressable32_intel($r5))
			&& (is_reg8_intel($r5) || is_segreg_intel($r5)
			|| is_reg16_intel($r5) || is_reg32_intel($r5)
			|| is_reg_mm_intel($r5) || is_reg_fpu_intel($r5)) );
		my $was64 = is_reg64_intel($r3) + is_reg64_intel($r5) + is_reg64_intel($r6);
		my $nregs = is_reg_intel($r3) + is_reg_intel($r5) + is_reg_intel($r6);
		return 0 if ( $was64 != 0 && $was64 != $nregs );
		return 0 if ( is_reg_intel($r6) && is_reg_intel($r5) );
		return 0 if ( is_reg_intel($r3) && $r2 =~ /-/o );
		return 0 if ( (is_reg_intel($r5) || is_reg_intel($r6)) && $r4 =~ /-/o );
		return 0 if ( ($r5 =~ /\brsp\b/io || $r5 =~ /\brip\b/io) && $r6 =~ /\b\d+\b/o && $r6 != 1 );
		return 0 if ( ($r6 =~ /\brsp\b/io || $r6 =~ /\brip\b/io) && $r5 =~ /\b\d+\b/o && $r5 != 1 );
		return 0 if ( is_reg_intel($r5) && $r6 =~ /\b\d+\b/o && $r6 != 1
			&& $r6 != 2 && $r6 != 4 && $r6 != 8);
		return 0 if ( is_reg_intel($r6) && $r5 =~ /\b\d+\b/o && $r5 != 1
			&& $r5 != 2 && $r5 != 4 && $r5 != 8);

		return 1;
	}
	elsif (	$elem =~ /^\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*\]$/o
		|| $elem =~ /^(\w+)\s*:\s*\[\s*([\+\-\(\)]*)\s*(\w+)\s*\]$/o) {

		my ($r1, $r2, $r3) = ($1, $2, $3);

		return 0 if ( is_segreg_intel($r3) || ! is_segreg_intel($r1) );
		return 0 if ( (! is_reg64_intel($r3) && ! is_r32_in64_intel($r3))
			&& (is_reg8_intel($r3) || is_segreg_intel($r3)
			|| is_reg16_intel($r3) || is_reg32_intel($r3)
			|| is_reg_mm_intel($r3) || is_reg_fpu_intel($r3)) );
		return 0 if ( is_reg_intel($r3) && $r2 =~ /-/o );

		return 1;
	}
	elsif (	$elem =~ /^\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]$/o
		|| $elem =~ /^(\w+)\s*:\s*\[\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]$/o) {

		my ($r1, $r2, $r3, $r4) = ($1, $2, $3, $4);

		return 0 if ( is_segreg_intel($r3) || is_segreg_intel($r4) || ! is_segreg_intel($r1) );
		return 0 if ( (! is_reg64_intel($r3) && ! is_r32_in64_intel($r3) && ! is_addressable32_intel($r3))
			&& (is_reg8_intel($r3) || is_segreg_intel($r3)
			|| is_reg16_intel($r3) || is_reg32_intel($r3)
			|| is_reg_mm_intel($r3) || is_reg_fpu_intel($r3)) );
		return 0 if ( (! is_reg64_intel($r4) && ! is_r32_in64_intel($r4) && ! is_addressable32_intel($r4))
			&& (is_reg8_intel($r4) || is_segreg_intel($r4)
			|| is_reg16_intel($r4) || is_reg32_intel($r4)
			|| is_reg_mm_intel($r4) || is_reg_fpu_intel($r4)) );
		my $was64 = is_reg64_intel($r3) + is_reg64_intel($r4);
		my $nregs = is_reg_intel($r3) + is_reg_intel($r4);
		return 0 if ( $was64 != 0 && $was64 != $nregs );
		return 0 if ( is_reg_intel($r3) && is_reg_intel($r4) );
		return 0 if ( is_reg_intel($r3) && $r2 =~ /-/o );
		return 0 if ( (is_reg_intel($r3) || is_reg_intel($r4)) && $r2 =~ /-/o );
		return 0 if ( ($r3 =~ /\brsp\b/io || $r3 =~ /\brip\b/io) && $r4 =~ /\b\d+\b/o && $r4 != 1 );
		return 0 if ( ($r4 =~ /\brsp\b/io || $r4 =~ /\brip\b/io) && $r3 =~ /\b\d+\b/o && $r3 != 1 );
		return 0 if ( is_reg_intel($r3) && $r4 =~ /\b\d+\b/o && $r4 != 1
			&& $r4 != 2 && $r4 != 4 && $r4 != 8);
		return 0 if ( is_reg_intel($r4) && $r3 =~ /\b\d+\b/o && $r3 != 1
			&& $r3 != 2 && $r3 != 4 && $r3 != 8);

		return 1;
	}
	elsif (	$elem =~ /^\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]*)\s*(\w+)\s*\]$/o
		|| $elem =~ /^(\w+)\s*:\s*\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]*)\s*(\w+)\s*\]$/o) {

		my ($r1, $r2, $r3, $r4, $r5) = ($1, $2, $3, $4, $5);

		return 0 if ( is_segreg_intel($r3) || is_segreg_intel($r5) || ! is_segreg_intel($r1) );
		return 0 if ( (! is_reg64_intel($r3) && ! is_r32_in64_intel($r3) && ! is_addressable32_intel($r3))
			&& (is_reg8_intel($r3) || is_segreg_intel($r3)
			|| is_reg16_intel($r3) || is_reg32_intel($r3)
			|| is_reg_mm_intel($r3) || is_reg_fpu_intel($r3)) );
		return 0 if ( (! is_reg64_intel($r5) && ! is_r32_in64_intel($r5) && ! is_addressable32_intel($r5))
			&& (is_reg8_intel($r5) || is_segreg_intel($r5)
			|| is_reg16_intel($r5) || is_reg32_intel($r5)
			|| is_reg_mm_intel($r5) || is_reg_fpu_intel($r5)) );
		my $was64 = is_reg64_intel($r3) + is_reg64_intel($r5);
		my $nregs = is_reg_intel($r3) + is_reg_intel($r5);
		return 0 if ( $was64 != 0 && $was64 != $nregs );
		return 0 if ( is_reg_intel($r3) && $r2 =~ /-/o );
		return 0 if ( is_reg_intel($r5) && $r4 =~ /-/o );

		return 1;
	}
	elsif (	$elem =~ /^\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]$/o ) {

		my ($r2, $r3, $r4, $r5, $r6, $r7, $r8) = ($1, $2, $3, $4, $5, $6, $7);

		return 0 if ( is_segreg_intel($r3) || is_segreg_intel($r6) || is_segreg_intel($r5)
			|| is_segreg_intel($r8) );
		return 0 if ( (! is_reg64_intel($r3) && ! is_r32_in64_intel($r3) && ! is_addressable32_intel($r3))
			&& (is_reg8_intel($r3) || is_segreg_intel($r3)
			|| is_reg16_intel($r3) || is_reg32_intel($r3)
			|| is_reg_mm_intel($r3) || is_reg_fpu_intel($r3)) );
		return 0 if ( (! is_reg64_intel($r6) && ! is_r32_in64_intel($r6) && ! is_addressable32_intel($r6))
			&& (is_reg8_intel($r6) || is_segreg_intel($r6)
			|| is_reg16_intel($r6) || is_reg32_intel($r6)
			|| is_reg_mm_intel($r6) || is_reg_fpu_intel($r6)) );
		return 0 if ( (! is_reg64_intel($r5) && ! is_r32_in64_intel($r5) && ! is_addressable32_intel($r5))
			&& (is_reg8_intel($r5) || is_segreg_intel($r5)
			|| is_reg16_intel($r5) || is_reg32_intel($r5)
			|| is_reg_mm_intel($r5) || is_reg_fpu_intel($r5)) );
		return 0 if ( (! is_reg64_intel($r8) && ! is_r32_in64_intel($r8) && ! is_addressable32_intel($r8))
			&& (is_reg8_intel($r8) || is_segreg_intel($r8)
			|| is_reg16_intel($r8) || is_reg32_intel($r8)
			|| is_reg_mm_intel($r8) || is_reg_fpu_intel($r8)) );
		my $was64 = is_reg64_intel($r3) + is_reg64_intel($r5) + is_reg64_intel($r6) + is_reg64_intel($r8);
		my $nregs = is_reg_intel($r3) + is_reg_intel($r5) + is_reg_intel($r6) + is_reg_intel($r8);
		return 0 if ( $was64 != 0 && $was64 != $nregs );
		return 0 if ( is_reg_intel($r6) && is_reg_intel($r5) );
		return 0 if ( is_reg_intel($r3) && $r2 =~ /-/o );
		return 0 if ( (is_reg_intel($r5) || is_reg_intel($r6)) && $r4 =~ /-/o );
		return 0 if ( is_reg_intel($r8) && $r7 =~ /-/o );
		return 0 if ( ($r5 =~ /\brsp\b/io || $r5 =~ /\brip\b/io) && $r6 =~ /\b\d+\b/o && $r6 != 1 );
		return 0 if ( ($r6 =~ /\brsp\b/io || $r6 =~ /\brip\b/io) && $r5 =~ /\b\d+\b/o && $r5 != 1 );
		return 0 if ( is_reg_intel($r5) && $r6 =~ /\b\d+\b/o && $r6 != 1
			&& $r6 != 2 && $r6 != 4 && $r6 != 8);
		return 0 if ( is_reg_intel($r6) && $r5 =~ /\b\d+\b/o && $r5 != 1
			&& $r5 != 2 && $r5 != 4 && $r5 != 8);
		return 0 if ( is_reg_intel($r3) && (is_reg_intel($r5) || is_reg_intel($r6)) && is_reg_intel($r8) );

		return 1;
	}
	elsif (	$elem =~ /^\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]$/o ) {

		my ($r2, $r3, $r7, $r8, $r4, $r5, $r6) = ($1, $2, $3, $4, $5, $6, $7);

		return 0 if ( is_segreg_intel($r3) || is_segreg_intel($r6) || is_segreg_intel($r5)
			|| is_segreg_intel($r8) );
		return 0 if ( (! is_reg64_intel($r3) && ! is_r32_in64_intel($r3) && ! is_addressable32_intel($r3))
			&& (is_reg8_intel($r3) || is_segreg_intel($r3)
			|| is_reg16_intel($r3) || is_reg32_intel($r3)
			|| is_reg_mm_intel($r3) || is_reg_fpu_intel($r3)) );
		return 0 if ( (! is_reg64_intel($r6) && ! is_r32_in64_intel($r6) && ! is_addressable32_intel($r6))
			&& (is_reg8_intel($r6) || is_segreg_intel($r6)
			|| is_reg16_intel($r6) || is_reg32_intel($r6)
			|| is_reg_mm_intel($r6) || is_reg_fpu_intel($r6)) );
		return 0 if ( (! is_reg64_intel($r5) && ! is_r32_in64_intel($r5) && ! is_addressable32_intel($r5))
			&& (is_reg8_intel($r5) || is_segreg_intel($r5)
			|| is_reg16_intel($r5) || is_reg32_intel($r5)
			|| is_reg_mm_intel($r5) || is_reg_fpu_intel($r5)) );
		return 0 if ( (! is_reg64_intel($r8) && ! is_r32_in64_intel($r8) && ! is_addressable32_intel($r8))
			&& (is_reg8_intel($r8) || is_segreg_intel($r8)
			|| is_reg16_intel($r8) || is_reg32_intel($r8)
			|| is_reg_mm_intel($r8) || is_reg_fpu_intel($r8)) );
		my $was64 = is_reg64_intel($r3) + is_reg64_intel($r5) + is_reg64_intel($r6) + is_reg64_intel($r8);
		my $nregs = is_reg_intel($r3) + is_reg_intel($r5) + is_reg_intel($r6) + is_reg_intel($r8);
		return 0 if ( $was64 != 0 && $was64 != $nregs );
		return 0 if ( is_reg_intel($r6) && is_reg_intel($r5) );
		return 0 if ( is_reg_intel($r3) && $r2 =~ /-/o );
		return 0 if ( (is_reg_intel($r5) || is_reg_intel($r6)) && $r4 =~ /-/o );
		return 0 if ( is_reg_intel($r8) && $r7 =~ /-/o );
		return 0 if ( ($r5 =~ /\brsp\b/io || $r5 =~ /\brip\b/io) && $r6 =~ /\b\d+\b/o && $r6 != 1 );
		return 0 if ( ($r6 =~ /\brsp\b/io || $r6 =~ /\brip\b/io) && $r5 =~ /\b\d+\b/o && $r5 != 1 );
		return 0 if ( is_reg_intel($r5) && $r6 =~ /\b\d+\b/o && $r6 != 1
			&& $r6 != 2 && $r6 != 4 && $r6 != 8);
		return 0 if ( is_reg_intel($r6) && $r5 =~ /\b\d+\b/o && $r5 != 1
			&& $r5 != 2 && $r5 != 4 && $r5 != 8);
		return 0 if ( is_reg_intel($r3) && (is_reg_intel($r5) || is_reg_intel($r6)) && is_reg_intel($r8) );

		return 1;
	}
	elsif (	$elem =~ /^\[\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]$/o ) {

		my ($r4, $r5, $r6, $r2, $r3, $r7, $r8) = ($1, $2, $3, $4, $5, $6, $7);

		return 0 if ( is_segreg_intel($r3) || is_segreg_intel($r6) || is_segreg_intel($r5)
			|| is_segreg_intel($r8) );
		return 0 if ( (! is_reg64_intel($r3) && ! is_r32_in64_intel($r3) && ! is_addressable32_intel($r3))
			&& (is_reg8_intel($r3) || is_segreg_intel($r3)
			|| is_reg16_intel($r3) || is_reg32_intel($r3)
			|| is_reg_mm_intel($r3) || is_reg_fpu_intel($r3)) );
		return 0 if ( (! is_reg64_intel($r6) && ! is_r32_in64_intel($r6) && ! is_addressable32_intel($r6))
			&& (is_reg8_intel($r6) || is_segreg_intel($r6)
			|| is_reg16_intel($r6) || is_reg32_intel($r6)
			|| is_reg_mm_intel($r6) || is_reg_fpu_intel($r6)) );
		return 0 if ( (! is_reg64_intel($r5) && ! is_r32_in64_intel($r5) && ! is_addressable32_intel($r5))
			&& (is_reg8_intel($r5) || is_segreg_intel($r5)
			|| is_reg16_intel($r5) || is_reg32_intel($r5)
			|| is_reg_mm_intel($r5) || is_reg_fpu_intel($r5)) );
		return 0 if ( (! is_reg64_intel($r8) && ! is_r32_in64_intel($r8) && ! is_addressable32_intel($r8))
			&& (is_reg8_intel($r8) || is_segreg_intel($r8)
			|| is_reg16_intel($r8) || is_reg32_intel($r8)
			|| is_reg_mm_intel($r8) || is_reg_fpu_intel($r8)) );
		my $was64 = is_reg64_intel($r3) + is_reg64_intel($r5) + is_reg64_intel($r6) + is_reg64_intel($r8);
		my $nregs = is_reg_intel($r3) + is_reg_intel($r5) + is_reg_intel($r6) + is_reg_intel($r8);
		return 0 if ( $was64 != 0 && $was64 != $nregs );
		return 0 if ( is_reg_intel($r6) && is_reg_intel($r5) );
		return 0 if ( is_reg_intel($r3) && $r2 =~ /-/o );
		return 0 if ( (is_reg_intel($r5) || is_reg_intel($r6)) && $r4 =~ /-/o );
		return 0 if ( is_reg_intel($r8) && $r7 =~ /-/o );
		return 0 if ( ($r5 =~ /\brsp\b/io || $r5 =~ /\brip\b/io) && $r6 =~ /\b\d+\b/o && $r6 != 1 );
		return 0 if ( ($r6 =~ /\brsp\b/io || $r6 =~ /\brip\b/io) && $r5 =~ /\b\d+\b/o && $r5 != 1 );
		return 0 if ( is_reg_intel($r5) && $r6 =~ /\b\d+\b/o && $r6 != 1
			&& $r6 != 2 && $r6 != 4 && $r6 != 8);
		return 0 if ( is_reg_intel($r6) && $r5 =~ /\b\d+\b/o && $r5 != 1
			&& $r5 != 2 && $r5 != 4 && $r5 != 8);
		return 0 if ( is_reg_intel($r3) && (is_reg_intel($r5) || is_reg_intel($r6)) && is_reg_intel($r8) );

		return 1;
	}
	elsif (	$elem =~ /^\[\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]$/o ) {

		my ($r4, $r5, $r6, $r2, $r3) = ($1, $2, $3, $4, $5, $6);

		return 0 if ( is_segreg_intel($r3) || is_segreg_intel($r6) || is_segreg_intel($r5) );
		return 0 if ( (! is_reg64_intel($r3) && ! is_r32_in64_intel($r3) && ! is_addressable32_intel($r3))
			&& (is_reg8_intel($r3) || is_segreg_intel($r3)
			|| is_reg16_intel($r3) || is_reg32_intel($r3)
			|| is_reg_mm_intel($r3) || is_reg_fpu_intel($r3)) );
		return 0 if ( (! is_reg64_intel($r6) && ! is_r32_in64_intel($r6) && ! is_addressable32_intel($r6))
			&& (is_reg8_intel($r6) || is_segreg_intel($r6)
			|| is_reg16_intel($r6) || is_reg32_intel($r6)
			|| is_reg_mm_intel($r6) || is_reg_fpu_intel($r6)) );
		return 0 if ( (! is_reg64_intel($r5) && ! is_r32_in64_intel($r5) && ! is_addressable32_intel($r5))
			&& (is_reg8_intel($r5) || is_segreg_intel($r5)
			|| is_reg16_intel($r5) || is_reg32_intel($r5)
			|| is_reg_mm_intel($r5) || is_reg_fpu_intel($r5)) );
		my $was64 = is_reg64_intel($r3) + is_reg64_intel($r5) + is_reg64_intel($r6);
		my $nregs = is_reg_intel($r3) + is_reg_intel($r5) + is_reg_intel($r6);
		return 0 if ( $was64 != 0 && $was64 != $nregs );
		return 0 if ( is_reg_intel($r6) && is_reg_intel($r5) );
		return 0 if ( is_reg_intel($r3) && $r2 =~ /-/o );
		return 0 if ( (is_reg_intel($r5) || is_reg_intel($r6)) && $r4 =~ /-/o );
		return 0 if ( ($r5 =~ /\brsp\b/io || $r5 =~ /\brip\b/io) && $r6 =~ /\b\d+\b/o && $r6 != 1 );
		return 0 if ( ($r6 =~ /\brsp\b/io || $r6 =~ /\brip\b/io) && $r5 =~ /\b\d+\b/o && $r5 != 1 );
		return 0 if ( is_reg_intel($r5) && $r6 =~ /\b\d+\b/o && $r6 != 1
			&& $r6 != 2 && $r6 != 4 && $r6 != 8);
		return 0 if ( is_reg_intel($r6) && $r5 =~ /\b\d+\b/o && $r5 != 1
			&& $r5 != 2 && $r5 != 4 && $r5 != 8);

		return 1;
	}
	elsif (	$elem =~ /^\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]$/o ) {

		my ($r2, $r3, $r4, $r5, $r7, $r8) = ($1, $2, $3, $4, $5, $6);

		return 0 if ( is_segreg_intel($r3) || is_segreg_intel($r5) || is_segreg_intel($r8) );
		return 0 if ( (! is_reg64_intel($r3) && ! is_r32_in64_intel($r3) && ! is_addressable32_intel($r3))
			&& (is_reg8_intel($r3) || is_segreg_intel($r3)
			|| is_reg16_intel($r3) || is_reg32_intel($r3)
			|| is_reg_mm_intel($r3) || is_reg_fpu_intel($r3)) );
		return 0 if ( (! is_reg64_intel($r5) && ! is_r32_in64_intel($r5) && ! is_addressable32_intel($r5))
			&& (is_reg8_intel($r5) || is_segreg_intel($r5)
			|| is_reg16_intel($r5) || is_reg32_intel($r5)
			|| is_reg_mm_intel($r5) || is_reg_fpu_intel($r5)) );
		return 0 if ( (! is_reg64_intel($r8) && ! is_r32_in64_intel($r8) && ! is_addressable32_intel($r8))
			&& (is_reg8_intel($r8) || is_segreg_intel($r8)
			|| is_reg16_intel($r8) || is_reg32_intel($r8)
			|| is_reg_mm_intel($r8) || is_reg_fpu_intel($r8)) );
		my $was64 = is_reg64_intel($r3) + is_reg64_intel($r5) + is_reg64_intel($r8);
		my $nregs = is_reg_intel($r3) + is_reg_intel($r5) + is_reg_intel($r8);
		return 0 if ( $was64 != 0 && $was64 != $nregs );
		return 0 if ( is_reg_intel($r3) && $r2 =~ /-/o );
		return 0 if ( is_reg_intel($r5) && $r4 =~ /-/o );
		return 0 if ( is_reg_intel($r8) && $r7 =~ /-/o );
		return 0 if ( is_reg_intel($r3) && is_reg_intel($r5) && is_reg_intel($r8) );

		return 1;
	}
	elsif (	$elem =~ /^\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]$/o ) {

		my ($r2, $r3, $r4, $r5, $r6) = ($1, $2, $3, $4, $5);

		return 0 if ( is_segreg_intel($r3) || is_segreg_intel($r6) || is_segreg_intel($r5) );
		return 0 if ( (! is_reg64_intel($r3) && ! is_r32_in64_intel($r3) && ! is_addressable32_intel($r3))
			&& (is_reg8_intel($r3) || is_segreg_intel($r3)
			|| is_reg16_intel($r3) || is_reg32_intel($r3)
			|| is_reg_mm_intel($r3) || is_reg_fpu_intel($r3)) );
		return 0 if ( (! is_reg64_intel($r6) && ! is_r32_in64_intel($r6) && ! is_addressable32_intel($r6))
			&& (is_reg8_intel($r6) || is_segreg_intel($r6)
			|| is_reg16_intel($r6) || is_reg32_intel($r6)
			|| is_reg_mm_intel($r6) || is_reg_fpu_intel($r6)) );
		return 0 if ( (! is_reg64_intel($r5) && ! is_r32_in64_intel($r5) && ! is_addressable32_intel($r5))
			&& (is_reg8_intel($r5) || is_segreg_intel($r5)
			|| is_reg16_intel($r5) || is_reg32_intel($r5)
			|| is_reg_mm_intel($r5) || is_reg_fpu_intel($r5)) );
		my $was64 = is_reg64_intel($r3) + is_reg64_intel($r5) + is_reg64_intel($r6);
		my $nregs = is_reg_intel($r3) + is_reg_intel($r5) + is_reg_intel($r6);
		return 0 if ( $was64 != 0 && $was64 != $nregs );
		return 0 if ( is_reg_intel($r6) && is_reg_intel($r5) );
		return 0 if ( is_reg_intel($r3) && $r2 =~ /-/o );
		return 0 if ( (is_reg_intel($r5) || is_reg_intel($r6)) && $r4 =~ /-/o );
		return 0 if ( ($r5 =~ /\brsp\b/io || $r5 =~ /\brip\b/io) && $r6 =~ /\b\d+\b/o && $r6 != 1 );
		return 0 if ( ($r6 =~ /\brsp\b/io || $r6 =~ /\brip\b/io) && $r5 =~ /\b\d+\b/o && $r5 != 1 );
		return 0 if ( is_reg_intel($r5) && $r6 =~ /\b\d+\b/o && $r6 != 1
			&& $r6 != 2 && $r6 != 4 && $r6 != 8);
		return 0 if ( is_reg_intel($r6) && $r5 =~ /\b\d+\b/o && $r5 != 1
			&& $r5 != 2 && $r5 != 4 && $r5 != 8);

		return 1;
	}
	elsif (	$elem =~ /^\[\s*([\+\-\(\)]*)\s*(\w+)\s*\]/o ) {

		my ($r2, $r3) = ($1, $2);

		return 0 if ( is_segreg_intel($r3) );
		return 0 if ( (! is_reg64_intel($r3) && ! is_r32_in64_intel($r3))
			&& (is_reg8_intel($r3) || is_segreg_intel($r3)
			|| is_reg16_intel($r3) || is_reg32_intel($r3)
			|| is_reg_mm_intel($r3) || is_reg_fpu_intel($r3)) );
		return 0 if ( is_reg_intel($r3) && $r2 =~ /-/o );

		return 1;
	}
	elsif (	$elem =~ /^\[\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]$/o ) {

		my ($r2, $r3, $r4) = ($1, $2, $3);

		return 0 if ( is_segreg_intel($r3) || is_segreg_intel($r4) );
		return 0 if ( (! is_reg64_intel($r3) && ! is_r32_in64_intel($r3) && ! is_addressable32_intel($r3))
			&& (is_reg8_intel($r3) || is_segreg_intel($r3)
			|| is_reg16_intel($r3) || is_reg32_intel($r3)
			|| is_reg_mm_intel($r3) || is_reg_fpu_intel($r3)) );
		return 0 if ( (! is_reg64_intel($r4) && ! is_r32_in64_intel($r4) && ! is_addressable32_intel($r4))
			&& (is_reg8_intel($r4) || is_segreg_intel($r4)
			|| is_reg16_intel($r4) || is_reg32_intel($r4)
			|| is_reg_mm_intel($r4) || is_reg_fpu_intel($r4)) );
		my $was64 = is_reg64_intel($r3) + is_reg64_intel($r4);
		my $nregs = is_reg_intel($r3) + is_reg_intel($r4);
		return 0 if ( $was64 != 0 && $was64 != $nregs );
		return 0 if ( is_reg_intel($r3) && is_reg_intel($r4) );
		return 0 if ( is_reg_intel($r3) && $r2 =~ /-/o );
		return 0 if ( (is_reg_intel($r3) || is_reg_intel($r4)) && $r2 =~ /-/o );
		return 0 if ( ($r3 =~ /\brsp\b/io || $r3 =~ /\brip\b/io) && $r4 =~ /\b\d+\b/o && $r4 != 1 );
		return 0 if ( ($r4 =~ /\brsp\b/io || $r4 =~ /\brip\b/io) && $r3 =~ /\b\d+\b/o && $r3 != 1 );
		return 0 if ( is_reg_intel($r3) && $r4 =~ /\b\d+\b/o && $r4 != 1
			&& $r4 != 2 && $r4 != 4 && $r4 != 8);
		return 0 if ( is_reg_intel($r4) && $r3 =~ /\b\d+\b/o && $r3 != 1
			&& $r3 != 2 && $r3 != 4 && $r3 != 8);

		return 1;
	}
	elsif (	$elem =~ /^\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]*)\s*(\w+)\s*\]$/o ) {

		my ($r2, $r3, $r4, $r5) = ($1, $2, $3, $4);

		return 0 if ( is_segreg_intel($r3) || is_segreg_intel($r5) );
		return 0 if ( (! is_reg64_intel($r3) && ! is_r32_in64_intel($r3) && ! is_addressable32_intel($r3))
			&& (is_reg8_intel($r3) || is_segreg_intel($r3)
			|| is_reg16_intel($r3) || is_reg32_intel($r3)
			|| is_reg_mm_intel($r3) || is_reg_fpu_intel($r3)) );
		return 0 if ( (! is_reg64_intel($r5) && ! is_r32_in64_intel($r5) && ! is_addressable32_intel($r5))
			&& (is_reg8_intel($r5) || is_segreg_intel($r5)
			|| is_reg16_intel($r5) || is_reg32_intel($r5)
			|| is_reg_mm_intel($r5) || is_reg_fpu_intel($r5)) );
		my $was64 = is_reg64_intel($r3) + is_reg64_intel($r5);
		my $nregs = is_reg_intel($r3) + is_reg_intel($r5);
		return 0 if ( $was64 != 0 && $was64 != $nregs );
		return 0 if ( is_reg_intel($r3) && $r2 =~ /-/o );
		return 0 if ( is_reg_intel($r5) && $r4 =~ /-/o );

		return 1;
	}
	return 0;
}

=head2 is_valid_64bit_addr_att

 Checks if the given string parameter (must contain the parentheses)
  is a valid x86 64-bit addressing mode in AT&T syntax.
 Returns 1 if yes.

=cut

sub is_valid_64bit_addr_att($) {

	my $elem = shift;
	if ( $elem =~ /^([%\w]+):\s*\(\s*([+-]*)\s*([%\w]+)\s*\)$/o ) {

		my ($r1, $r2, $sign) = ($1, $3, $2);
		return 0 if (! is_segreg_att ($r1)) || is_segreg_att ($r2);
		return 0 if is_reg_att($r2) && (! is_r32_in64_att($r2))
			&& (!is_addressable32_att($r2)) && (! is_reg64_att($r2));
		return 0 if is_reg64_att($r2) && $sign =~ /-/o;
		return 1;
	}
	elsif ( $elem =~ /^([%\w]+):\s*\(\s*([%\w]+)\s*,\s*([%\w]+)\s*\)$/o ) {

		my ($r1, $r2, $r3) = ($1, $2, $3);
		return 0 if (! is_segreg_att ($r1)) || is_segreg_att ($r2) || is_segreg_att ($r3);
		return 0 if (! is_reg_att($r2)) || (! is_reg_att($r3));
		return 0 if is_reg_att($r2) && (! is_r32_in64_att($r2))
			&& (!is_addressable32_att($r2)) && (! is_reg64_att($r2));
		return 0 if is_reg_att($r3) && (! is_r32_in64_att($r3))
			&& (!is_addressable32_att($r3)) && (! is_reg64_att($r3));
		my $was64 = is_reg64_att($r2) + is_reg64_att($r3);
		my $nregs = is_reg_att($r2) + is_reg_att($r3);
		return 0 if ( $was64 != 0 && $was64 != $nregs );
		return 1;
	}
	elsif ( $elem =~ /^([%\w]+):\s*\(\s*([%\w]+)\s*,\s*([%\w]+)\s*,\s*(\d+)\s*\)$/o ) {

		my ($r1, $r2, $r3, $scale) = ($1, $2, $3, $4);
		return 0 if (! is_segreg_att ($r1)) || is_segreg_att ($r2) || is_segreg_att ($r3);
		return 0 if (! is_reg_att($r2)) || (! is_reg_att($r3));
		return 0 if is_reg_att($r2) && (! is_r32_in64_att($r2))
			&& (!is_addressable32_att($r2)) && (! is_reg64_att($r2));
		return 0 if is_reg_att($r3) && (! is_r32_in64_att($r3))
			&& (!is_addressable32_att($r3)) && (! is_reg64_att($r3));
		return 0 if $r3 =~ /^%rsp$/io || $r3 =~ /^%rip$/io;
		return 0 if $scale != 1 && $scale != 2 && $scale != 4 && $scale != 8;
		my $was64 = is_reg64_att($r2) + is_reg64_att($r3);
		my $nregs = is_reg_att($r2) + is_reg_att($r3);
		return 0 if ( $was64 != 0 && $was64 != $nregs );
		return 1;
	}
	elsif ( $elem =~ /^([%\w]+):\s*\(\s*,\s*([%\w]+)\s*,\s*(\d+)\s*\)$/o ) {

		my ($r1, $r3, $scale) = ($1, $2, $3);
		return 0 if (! is_segreg_att ($r1)) || is_segreg_att ($r3);
		return 0 if ! is_reg_att($r3);
		return 0 if is_reg_att($r3) && (! is_r32_in64_att($r3))
			&& (!is_addressable32_att($r3)) && (! is_reg64_att($r3));
		return 0 if $r3 =~ /^%rsp$/io || $r3 =~ /^%rip$/io;
		return 0 if $scale != 1 && $scale != 2 && $scale != 4 && $scale != 8;
		return 1;
	}
	elsif ( $elem =~ /^([%\w]+):\s*[+-]*\s*([%\w]+)\s*\(\s*([+-]*)\s*([%\w]+)\s*\)$/o ) {

		my ($r1, $r2, $var, $sign) = ($1, $4, $2, $3);
		return 0 if (! is_segreg_att ($r1)) || is_segreg_att ($r2);
		return 0 if is_reg_att($r2) && (! is_r32_in64_att($r2))
			&& (!is_addressable32_att($r2)) && (! is_reg64_att($r2));
		return 0 if is_reg64_att($r2) && $sign =~ /-/o;
		return 0 if is_reg_att($var);
		return 1;
	}
	elsif ( $elem =~ /^([%\w]+):\s*[+-]*\s*([%\w]+)\s*\(\s*([%\w]+)\s*,\s*([%\w]+)\s*\)$/o ) {

		my ($r1, $r2, $r3, $var) = ($1, $3, $4, $2);
		return 0 if (! is_segreg_att ($r1)) || is_segreg_att ($r2) || is_segreg_att ($r3);
		return 0 if (! is_reg64_att($r2)) || (! is_reg64_att($r3));
		return 0 if is_reg_att($r2) && (! is_r32_in64_att($r2))
			&& (!is_addressable32_att($r2)) && (! is_reg64_att($r2));
		return 0 if is_reg_att($r3) && (! is_r32_in64_att($r3))
			&& (!is_addressable32_att($r3)) && (! is_reg64_att($r3));
		return 0 if is_reg_att($var);
		my $was64 = is_reg64_att($r2) + is_reg64_att($r3);
		my $nregs = is_reg_att($r2) + is_reg_att($r3);
		return 0 if ( $was64 != 0 && $was64 != $nregs );
		return 1;
	}
	elsif ( $elem =~ /^([%\w]+):\s*[+-]*\s*([%\w]+)\s*\(\s*([%\w]+)\s*,\s*([%\w]+)\s*,\s*(\d+)\s*\)$/o ) {

		my ($r1, $r2, $r3, $var, $scale) = ($1, $3, $4, $2, $5);
		return 0 if (! is_segreg_att ($r1)) || is_segreg_att ($r2) || is_segreg_att ($r3);
		return 0 if (! is_reg64_att($r2)) || (! is_reg64_att($r3));
		return 0 if is_reg_att($r2) && (! is_r32_in64_att($r2))
			&& (!is_addressable32_att($r2)) && (! is_reg64_att($r2));
		return 0 if is_reg_att($r3) && (! is_r32_in64_att($r3))
			&& (!is_addressable32_att($r3)) && (! is_reg64_att($r3));
		return 0 if is_reg_att($var);
		return 0 if $r3 =~ /^%rsp$/io || $r3 =~ /^%rip$/io;
		return 0 if $scale != 1 && $scale != 2 && $scale != 4 && $scale != 8;
		my $was64 = is_reg64_att($r2) + is_reg64_att($r3);
		my $nregs = is_reg_att($r2) + is_reg_att($r3);
		return 0 if ( $was64 != 0 && $was64 != $nregs );
		return 1;
	}
	elsif ( $elem =~ /^([%\w]+):\s*[+-]*\s*([%\w]+)\s*\(\s*,\s*([%\w]+)\s*,\s*(\d+)\s*\)$/o ) {

		my ($r1, $r3, $var, $scale) = ($1, $3, $2, $4);
		return 0 if (! is_segreg_att ($r1)) || is_segreg_att ($r3);
		return 0 if ! is_reg64_att($r3);
		return 0 if is_reg_att($r3) && (! is_r32_in64_att($r3))
			&& (!is_addressable32_att($r3)) && (! is_reg64_att($r3));
		return 0 if is_reg_att($var);
		return 0 if $r3 =~ /^%rsp$/io || $r3 =~ /^%rip$/io;
		return 0 if $scale != 1 && $scale != 2 && $scale != 4 && $scale != 8;
		return 1;
	}
	elsif ( $elem =~ /^([%\w]+):\s*[+-]*\s*([%\w]+)\s*\(\s*,\s*1\s*\)$/o ) {

		# special form: varname(1,)
		my ($r1, $var) = ($1, $2);
		return 0 if is_reg_att($var) || ! is_segreg_att ($r1);
		return 1;
	}
	elsif ( $elem =~ /^\(\s*([+-]*)\s*([%\w]+)\s*\)$/o ) {

		my ($r2, $sign) = ($2, $1);
		return 0 if is_segreg_att ($r2);
		return 0 if is_reg_att($r2) && (! is_r32_in64_att($r2))
			&& (!is_addressable32_att($r2)) && (! is_reg64_att($r2));
		return 0 if is_reg64_att($r2) && $sign =~ /-/o;
		return 1;
	}
	elsif ( $elem =~ /^\(\s*([%\w]+)\s*,\s*([%\w]+)\s*\)$/o ) {

		my ($r2, $r3) = ($1, $2);
		return 0 if is_segreg_att ($r2) || is_segreg_att ($r3);
		return 0 if is_reg_att($r2) && (! is_r32_in64_att($r2))
			&& (!is_addressable32_att($r2)) && (! is_reg64_att($r2));
		return 0 if is_reg_att($r3) && (! is_r32_in64_att($r3))
			&& (!is_addressable32_att($r3)) && (! is_reg64_att($r3));
		return 0 if (! is_reg_att($r2)) || (! is_reg64_att($r3));
		my $was64 = is_reg64_att($r2) + is_reg64_att($r3);
		my $nregs = is_reg_att($r2) + is_reg_att($r3);
		return 0 if ( $was64 != 0 && $was64 != $nregs );
		return 1;
	}
	elsif ( $elem =~ /^\(\s*([%\w]+)\s*,\s*([%\w]+)\s*,\s*(\d+)\s*\)$/o ) {

		my ($r2, $r3, $scale) = ($1, $2, $3);
		return 0 if is_segreg_att ($r2) || is_segreg_att ($r3);
		return 0 if (! is_reg64_att($r2)) || (! is_reg64_att($r3));
		return 0 if is_reg_att($r2) && (! is_r32_in64_att($r2))
			&& (!is_addressable32_att($r2)) && (! is_reg64_att($r2));
		return 0 if is_reg_att($r3) && (! is_r32_in64_att($r3))
			&& (!is_addressable32_att($r3)) && (! is_reg64_att($r3));
		return 0 if $r3 =~ /^%rsp$/io || $r3 =~ /^%rip$/io;
		return 0 if $scale != 1 && $scale != 2 && $scale != 4 && $scale != 8;
		my $was64 = is_reg64_att($r2) + is_reg64_att($r3);
		my $nregs = is_reg_att($r2) + is_reg_att($r3);
		return 0 if ( $was64 != 0 && $was64 != $nregs );
		return 1;
	}
	elsif ( $elem =~ /^\(\s*,\s*([%\w]+)\s*,\s*(\d+)\s*\)$/o ) {

		my ($r3, $scale) = ($1, $2);
		return 0 if is_segreg_att ($r3);
		return 0 if ! is_reg64_att($r3);
		return 0 if is_reg_att($r3) && (! is_r32_in64_att($r3))
			&& (!is_addressable32_att($r3)) && (! is_reg64_att($r3));
		return 0 if $r3 =~ /^%rsp$/io || $r3 =~ /^%rip$/io;
		return 0 if $scale != 1 && $scale != 2 && $scale != 4 && $scale != 8;
		return 1;
	}
	elsif ( $elem =~ /^[+-]*\s*([%\w]+)\s*\(\s*([+-]*)\s*([%\w]+)\s*\)$/o ) {

		my ($r2, $var, $sign) = ($3, $1, $2);
		return 0 if is_segreg_att ($r2);
		return 0 if is_reg_att($r2) && (! is_r32_in64_att($r2))
			&& (!is_addressable32_att($r2)) && (! is_reg64_att($r2));
		return 0 if is_reg64_att($r2) && $sign =~ /-/o;
		return 0 if is_reg_att($var);
		return 1;
	}
	elsif ( $elem =~ /^[+-]*\s*([%\w]+)\s*\(\s*([%\w]+)\s*,\s*([%\w]+)\s*\)$/o ) {

		my ($r2, $r3, $var) = ($2, $3, $1);
		return 0 if is_segreg_att ($r2) || is_segreg_att ($r3);
		return 0 if (! is_reg_att($r2)) || (! is_reg64_att($r3));
		return 0 if is_reg_att($r2) && (! is_r32_in64_att($r2))
			&& (!is_addressable32_att($r2)) && (! is_reg64_att($r2));
		return 0 if is_reg_att($r3) && (! is_r32_in64_att($r3))
			&& (!is_addressable32_att($r3)) && (! is_reg64_att($r3));
		return 0 if is_reg_att($var);
		my $was64 = is_reg64_att($r2) + is_reg64_att($r3);
		my $nregs = is_reg_att($r2) + is_reg_att($r3);
		return 0 if ( $was64 != 0 && $was64 != $nregs );
		return 1;
	}
	elsif ( $elem =~ /^[+-]*\s*([%\w]+)\s*\(\s*([%\w]+)\s*,\s*([%\w]+)\s*,\s*(\d+)\s*\)$/o ) {

		my ($r2, $r3, $scale, $var) = ($2, $3, $4, $1);
		return 0 if is_segreg_att ($r2) || is_segreg_att ($r3);
		return 0 if (! is_reg64_att($r2)) || (! is_reg64_att($r3));
		return 0 if is_reg_att($r2) && (! is_r32_in64_att($r2))
			&& (!is_addressable32_att($r2)) && (! is_reg64_att($r2));
		return 0 if is_reg_att($r3) && (! is_r32_in64_att($r3))
			&& (!is_addressable32_att($r3)) && (! is_reg64_att($r3));
		return 0 if $r3 =~ /^%rsp$/io || $r3 =~ /^%rip$/io;
		return 0 if $scale != 1 && $scale != 2 && $scale != 4 && $scale != 8;
		return 0 if is_reg_att($var);
		my $was64 = is_reg64_att($r2) + is_reg64_att($r3);
		my $nregs = is_reg_att($r2) + is_reg_att($r3);
		return 0 if ( $was64 != 0 && $was64 != $nregs );
		return 1;
	}
	elsif ( $elem =~ /^[+-]*\s*([%\w]+)\s*\(\s*,\s*([%\w]+)\s*,\s*(\d+)\s*\)$/o ) {

		my ($r3, $scale, $var) = ($2, $3, $1);
		return 0 if is_segreg_att ($r3);
		return 0 if ! is_reg64_att($r3);
		return 0 if is_reg_att($r3) && (! is_r32_in64_att($r3))
			&& (!is_addressable32_att($r3)) && (! is_reg64_att($r3));
		return 0 if $r3 =~ /^%rsp$/io || $r3 =~ /^%rip$/io;
		return 0 if $scale != 1 && $scale != 2 && $scale != 4 && $scale != 8;
		return 0 if is_reg_att($var);
		return 1;
	}
	elsif ( $elem =~ /^[+-]*\s*([%\w]+)\s*\(\s*,\s*1\s*\)$/o ) {

		# special form: varname(1,)
		my $var = $1;
		return 0 if is_reg_att($var);
		return 1;
	}
	return 0;
}

=head2 is_valid_64bit_addr

 Checks if the given string parameter (must contain the parentheses)
  is a valid x86 64-bit addressing mode in AT&T or Intel syntax.
 Returns 1 if yes.

=cut

sub is_valid_64bit_addr($) {

	my $elem = shift;
	return    is_valid_64bit_addr_intel($elem)
		| is_valid_64bit_addr_att($elem);
}

=head2 is_valid_addr_intel

 Checks if the given string parameter (must contain the square braces)
  is a valid x86 addressing mode in Intel syntax.
 Returns 1 if yes.

=cut

sub is_valid_addr_intel($) {

	my $elem = shift;
	return    is_valid_16bit_addr_intel($elem)
		| is_valid_32bit_addr_intel($elem)
		| is_valid_64bit_addr_intel($elem);
}

=head2 is_valid_addr_att

 Checks if the given string parameter (must contain the braces)
  is a valid x86 addressing mode in AT&T syntax.
 Returns 1 if yes.

=cut

sub is_valid_addr_att($) {

	my $elem = shift;
	return    is_valid_16bit_addr_att($elem)
		| is_valid_32bit_addr_att($elem)
		| is_valid_64bit_addr_att($elem);
}

=head2 is_valid_addr

 Checks if the given string parameter (must contain the square braces)
  is a valid x86 addressing mode (Intel or AT&T syntax).
 Returns 1 if yes.

=cut

sub is_valid_addr($) {

	my $elem = shift;
	return    is_valid_addr_intel($elem)
		| is_valid_addr_att($elem);
}

=head2 add_percent

 PRIVATE SUBROUTINE.
 Add a percent character ('%') in front of each element in the array given as a parameter.
 Returns the new array.

=cut

sub add_percent(@) {

	my @result = ();
	foreach (@_) {
		push @result, "%$_";
	}
	return @result;
}

=head2 is_att_suffixed_instr

 PRIVATE SUBROUTINE.
 Tells if the given instruction is suffixed in AT&T syntax.
 Returns 1 if yes

=cut

sub is_att_suffixed_instr($) {

	my $elem = shift;
	foreach(@att_suff_instr) {
		return 1 if /^$elem$/i;
	}
	return 0;
}

=head2 is_att_suffixed_instr_fpu

 PRIVATE SUBROUTINE.
 Tells if the given FPU non-integer instruction is suffixed in AT&T syntax.
 Returns 1 if yes

=cut

sub is_att_suffixed_instr_fpu($) {

	my $elem = shift;
	foreach(@att_suff_instr_fpu) {
		return 1 if /^$elem$/i;
	}
	return 0;
}

=head2 add_att_suffix_instr

 PRIVATE SUBROUTINE.
 Creates the AT&T syntax instruction array from the Intel-syntax array.
 Returns the new array.

=cut

sub add_att_suffix_instr(@) {

	my @result = ();
	foreach (@_) {
		if ( is_att_suffixed_instr ($_) ) {

			push @result, $_."b";
			push @result, $_."w";
			push @result, $_."l";
		}
		else
		{
			# FPU instructions
			if ( /^fi(\w+)/io )
			{
				push @result, $_."s";
				push @result, $_."l";
				push @result, $_."q";
			}
			elsif ( is_att_suffixed_instr_fpu ($_) )
			{
				push @result, $_."s";
				push @result, $_."l";
				push @result, $_."t";
			}
			elsif ( /^\s*(mov[sz])x\s+([^,]+)\s*,\s*([^,]+)(.*)/io )
			{
				# add suffixes to MOVSX/MOVZX instructions
				my ($inst, $arg1, $arg2, $rest, $z1, $z2);
				$inst = $1;
				$z1 = $2;
				$z2 = $3;
				$rest = $4;
				($arg1 = $z1) =~ s/\s*$//o;
				($arg2 = $z2) =~ s/\s*$//o;
				if ( is_reg8($arg2) && is_reg32($arg1) ) {
					push @result, "${inst}bl";
				} elsif ( is_reg8($arg2) && is_reg16($arg1) ) {
					push @result, "${inst}bw";
				} elsif ( is_reg16($arg2) || is_reg32($arg1)  ) {
					push @result, "${inst}wl";
				}
				push @result, "$_";
			}
			elsif ( /^\s*cbw\b/io )
			{
				push @result, 'cbtw';
			}
			elsif ( /^\s*cbw\b/io )
			{
				push @result, 'cwtl';
			}
			elsif ( /^\s*cbw\b/io )
			{
				push @result, 'cwtd';
			}
			elsif ( /^\s*cbw\b/io )
			{
				push @result, 'cltd';
			}
			else
			{
				push @result, "$_";
			}
		}
	}
	return @result;
}

=head2 bezplusa

 PRIVATE SUBROUTINE.
 Removes unnecessary '+' characters from the beginning of the given string.
 Returns the resulting string (or '+' if it was empty).

=cut

sub bezplusa($) {

	my $elem = shift;
	$elem =~ s/^\s*\++//o;
	if ( $elem eq "" ) { $elem = "+"; }
	return $elem;
}


=head2 conv_att_addr_to_intel

 Converts the given string representing a valid AT&T addressing mode to Intel syntax.
 Returns the resulting string.

=cut

sub conv_att_addr_to_intel($) {

	my $par = shift;
	$par =~ s/%([a-zA-Z]+)/$1/go;
	# seg: disp(base, index, scale)
	$par =~ s/(\w+\s*:\s*)([\w\+\-\(\)]+)\s*\(\s*(\w+)\s*,\s*(\w+)\s*,\s*(\d)\s*\)/[$1$3+$5*$4+$2]/o;
	$par =~ s/(\w+\s*:\s*)([\w\+\-\(\)]+)\s*\(\s*(\w+)\s*,\s*(\w+)\s*,?\s*\)/[$1$3+$4+$2]/o;
	$par =~ s/(\w+\s*:\s*)\(\s*(\w+)\s*,\s*(\w+)\s*,\s*(\d)\s*\)/[$1$2+$3*$4]/o;
	$par =~ s/(\w+\s*:\s*)\(\s*(\w+)\s*,\s*(\w+)\s*,?\s*\)/[$1$2+$3]/o;
	$par =~ s/(\w+\s*:\s*)([\w\+\-\(\)]+)\s*\(\s*,\s*1\s*\)/[$1$2]/o;
	$par =~ s/(\w+\s*:\s*)([\w\+\-\(\)]+)\s*\(\s*,\s*(\w+)\s*,\s*(\d)\s*\)/[$1$3*$4+$2]/o;
	$par =~ s/(\w+\s*:\s*)([\w\+\-\(\)]+)\s*\(\s*(\w+)\s*\)/[$1$3+$2]/o;
	$par =~ s/(\w+\s*:\s*)\s*\(\s*,\s*(\w+)\s*,\s*(\d)\s*\)/[$1$2*$3]/o;
	$par =~ s/(\w+\s*:\s*)\(\s*(\w+)\s*\)/[$1$2]/o;

	# disp(base, index, scale)
	$par =~ s/([\w\+\-\(\)]+)\(\s*(\w+)\s*,\s*(\w+)\s*,\s*(\d)\s*\)/[$2+$3*$4+$1]/o;
	$par =~ s/([\w\+\-\(\)]+)\(\s*(\w+)\s*,\s*(\w+)\s*,?\s*\)/[$2+$3+$1]/o;
	$par =~ s/\(\s*(\w+)\s*,\s*(\w+)\s*,\s*(\d)\s*\)/\t[$1+$2*$3]/o;
	$par =~ s/\(\s*(\w+)\s*,\s*(\w+)\s*,?\s*\)/\t[$1+$2]/o;
	$par =~ s/([\w\+\-\(\)]+)\(\s*,\s*(\w+)\s*,\s*(\d)\s*\)/[$2*$3+$1]/o;
	$par =~ s/\(\s*,\s*(\w+)\s*,\s*(\d)\s*\)/[$1*$2]/o;

	# disp(, index)
	$par =~ s/([\w\-\+\(\)]+)\(\s*,\s*1\s*\)/[$1]/o;
	$par =~ s/([\w\-\+\(\)]+)\(\s*,\s*(\w+)\s*\)/[$2+$1]/o;

	# (base, index)
	$par =~ s/\(\s*,\s*1\s*\)/[$1]/o;
	$par =~ s/\(\s*,\s*(\w+)\s*\)/[$1]/o;

	# disp(base)
	$par =~ s/([\w\-\+\(\)]+)\(\s*(\w+)\s*\)/[$2+$1]/o unless $par =~ /st\(\d\)/io;
	$par =~ s/\(\s*(\w+)\s*\)/[$1]/o;

	return $par;
}

=head2 conv_intel_addr_to_att

 Converts the given string representing a valid Intel addressing mode to AT&T syntax.
 Returns the resulting string.

=cut

sub conv_intel_addr_to_att($) {

	my $par = shift;
	my ($a1, $a2, $a3, $z1, $z2, $z3);
	# seg: disp(base, index, scale)
	# [seg:base+index*scale+disp]
	if ( $par =~ 	 /\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/o ) {
		$a1 = $2;
		$a2 = $4;
		$a3 = $7;
		$z1 = bezplusa($a1);
		$z2 = bezplusa($a2);
		$z3 = bezplusa($a3);
		if ( is_reg($3) && is_reg($5) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/$1:($z3$8)$9($3,$5,$6)/o;
		} elsif ( is_reg($3) && is_reg($6) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/$1:($z3$8)$9($3,$6,$5)/o;
		} elsif ( is_reg($5) && is_reg($8) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/$1:($z1$3)$9($8,$5,$6)/o;
		} elsif ( is_reg($6) && is_reg($8) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/$1:($z1$3)$9($8,$6,$5)/o;
		} elsif ( is_reg($3) && is_reg($8) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/$1:($z2$5*$6)$9($3,$8)/o;
		} elsif ( is_reg($3) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/$1:($z3$8$z2$5*$6)$9($3)/o;
		} elsif ( is_reg($5) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/$1:($z3$8$z1$3)$9(,$5,$6)/o;
		} elsif ( is_reg($6) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/$1:($z3$8$z1$3)$9(,$6,$5)/o;
		} elsif ( is_reg($8) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/$1:($z1$3$z2$5*$6)$9($8)/o;
		} else {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/$1:($z1$3$z2$5*$6$z3$8)$9(,1)/o;
		}
	}
	elsif ( $par =~  /\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]/o ) {
		$a1 = $2;
		$a2 = $4;
		$a3 = $6;
		$z1 = bezplusa($a1);
		$z2 = bezplusa($a2);
		$z3 = bezplusa($a3);
		if ( is_reg($3) && is_reg($5) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]/$1:($z3$7*$8)$9($3,$5)/o;
		} elsif ( is_reg($5) && is_reg($7) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]/$1:($z1$3)$9($5,$7,$8)/o;
		} elsif ( is_reg($5) && is_reg($8) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]/$1:($z1$3)$9($5,$8,$7)/o;
		} elsif ( is_reg($3) && is_reg($7) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]/$1:($z2$5)$9($3,$7,$8)/o;
		} elsif ( is_reg($3) && is_reg($8) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]/$1:($z2$5)$9($3,$8,$7)/o;
		} elsif ( is_reg($3) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]/$1:($z2$5$z3$7*$8)$9($3)/o;
		} elsif ( is_reg($5) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]/$1:($z1$3$z3$7*$8)$9($5)/o;
		} elsif ( is_reg($7) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]/$1:($z1$3$z2$5)$9(,$7,$8)/o;
		} elsif ( is_reg($8) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]/$1:($z1$3$z2$5)$9(,$8,$7)/o;
		} else {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]/$1:($z1$3$z2$5$z3$7*$8)$9(,1)/o;
		}
	}
	elsif ( $par =~  /\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/o ) {
		$a1 = $2;
		$a2 = $5;
		$a3 = $7;
		$z1 = bezplusa($a1);
		$z2 = bezplusa($a2);
		$z3 = bezplusa($a3);
		if ( is_reg($3) && is_reg($6) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/$1:($z3$8)$9($6,$3,$4)/o;
		} elsif ( is_reg($4) && is_reg($6) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/$1:($z3$8)$9($6,$4,$3)/o;
		} elsif ( is_reg($6) && is_reg($8) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/$1:($z1$3*$4)$9($6,$8)/o;
		} elsif ( is_reg($3) && is_reg($8) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/$1:($z2$6)$9($8,$3,$4)/o;
		} elsif ( is_reg($4) && is_reg($8) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/$1:($z2$6)$9($8,$4,$3)/o;
		} elsif ( is_reg($3) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/$1:($z2$6$z3$8)$9(,$3,$4)/o;
		} elsif ( is_reg($4) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/$1:($z2$6$z3$8)$9(,$4,$3)/o;
		} elsif ( is_reg($6) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/$1:($z1$3*$4$z3$8)$9($6)/o;
		} elsif ( is_reg($8) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/$1:($z1$3*$4$z2$6)$9($8)/o;
		} else {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/$1:($z1$3*$4$z2$6$z3$8)$9(,1)/o;
		}
	}
	elsif ( $par =~  /\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/o ) {
		$a1 = $2;
		$a2 = $4;
		$a3 = $6;
		$z1 = bezplusa($a1);
		$z2 = bezplusa($a2);
		$z3 = bezplusa($a3);
		if ( is_reg($3) && is_reg($5) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/$1:($z3$7)$8($3,$5,)/o;
		} elsif ( is_reg($3) && is_reg($7) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/$1:($z2$5)$8($3,$7,)/o;
		} elsif ( is_reg($5) && is_reg($7) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/$1:($z1$3)$8($7,$5,)/o;
		} elsif ( is_reg($3) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/$1:($z1$5$z3$7)$8($3)/o;
		} elsif ( is_reg($5) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/$1:($z1$3$z3$7)$8($5)/o;
		} elsif ( is_reg($7) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/$1:($z1$3$z2$5)$8($7)/o;
		} else {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/$1:($z1$3$z2$5$z3$7)$8(,1)/o;
		}
	}
	elsif ( $par =~  /\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]/o ) {
		$a1 = $2;
		$a2 = $4;
		$z1 = bezplusa($a1);
		$z2 = bezplusa($a2);
		if ( is_reg($3) && is_reg($5) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]/$1:($3,$5,$6)/o;
		} elsif ( is_reg($3) && is_reg($6) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]/$1:($3,$6,$5)/o;
		} elsif ( is_reg($3) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]/$1:($z2$5*$6)$7($3)/o;
		} elsif ( is_reg($5) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]/$1:($z1$3)$7(,$5,$6)/o;
		} elsif ( is_reg($6) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]/$1:($z1$3)$7(,$6,$5)/o;
		} else {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]/$1:($z1$3$z2$5*$6)$7(,1)/o;
		}
	}
	elsif ( $par =~  /\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/o ) {
		$a1 = $2;
		$a2 = $4;
		$z1 = bezplusa($a1);
		$z2 = bezplusa($a2);
		if ( is_reg($3) && is_reg($5) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/$1:($3,$5,)/o;
		} elsif ( is_reg($3) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/$1:($z2$5)$6($3)/o;
		} elsif ( is_reg($5) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/$1:($z1$3)$6($5)/o;
		} else {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/$1:($z1$3$z2$5)$6(,1)/o;
		}
	}
	elsif ( $par =~  /\[\s*(\w+)\s*:\s*(\w+)\s*\]/o ) {
		if ( is_reg($2) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*(\w+)\s*\]/$1:($2)/o;
		} else {
			$par =~ s/\[\s*(\w+)\s*:\s*(\w+)\s*\]/$1:$2(,1)/o;
		}
	}
	elsif ( $par =~  /\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/o ) {
		$a1 = $2;
		$a2 = $5;
		$z1 = bezplusa($a1);
		$z2 = bezplusa($a2);
		if ( is_reg($3) && is_reg($6) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/$1:($6,$3,$4)/o;
		} elsif ( is_reg($4) && is_reg($6) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/$1:($6,$4,$3)/o;
		} elsif ( is_reg($3) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/$1:($z2$6)$7(,$3,$4)/o;
		} elsif ( is_reg($4) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/$1:($z2$6)$7(,$4,$3)/o;
		} elsif ( is_reg($6) ) {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/$1:($z1$3*$4)$7($6)/o;
		} else {
			$par =~ s/\[\s*(\w+)\s*:\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/$1:($z1$3*$4$z2$6)$7(,1)/o;
		}
	}

	# disp(base, index, scale)
	elsif ( $par =~  /\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/o ) {
		$a1 = $1;
		$a2 = $3;
		$a3 = $6;
		$z1 = bezplusa($a1);
		$z2 = bezplusa($a2);
		$z3 = bezplusa($a3);
		if ( is_reg($2) && is_reg($4) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/($z3$7)$8($2,$4,$5)/o;
		} elsif ( is_reg($2) && is_reg($5) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/($z3$7)$8($2,$5,$4)/o;
		} elsif ( is_reg($2) && is_reg($7) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/($z2$4*$5)$8($2,$7)/o;
		} elsif ( is_reg($4) && is_reg($7) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/($z1$2)$8($7,$4,$5)/o;
		} elsif ( is_reg($5) && is_reg($7) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/($z1$2)$8($7,$5,$4)/o;
		} elsif ( is_reg($2) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/($z3$7$z2$4*$5)$8($2)/o;
		} elsif ( is_reg($4) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/($z3$7+$z1$2)$8(,$4,$5)/o;
		} elsif ( is_reg($5) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/($z3$7+$z1$2)$8(,$5,$4)/o;
		} elsif ( is_reg($7) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/($z1$2$z2$4*$5)$8($7)/o;
		} else {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/($z1$2$z2$4*$5$z3$7)$8(,1)/o;
		}
	}
	elsif ( $par =~  /\[\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/o ) {
		$a1 = $1;
		$a2 = $4;
		$a3 = $6;
		$z1 = bezplusa($a1);
		$z2 = bezplusa($a2);
		$z3 = bezplusa($a3);
		if ( is_reg($2) && is_reg($5) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/($z3$7)$8($5,$2,$3)/o;
		} elsif ( is_reg($3) && is_reg($5) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/($z3$7)$8($5,$3,$2)/o;
		} elsif ( is_reg($2) && is_reg($7) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/($z2$5)$8($7,$2,$3)/o;
		} elsif ( is_reg($3) && is_reg($7) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/($z2$5)$8($7,$3,$2)/o;
		} elsif ( is_reg($5) && is_reg($7) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/($z1$2*$3)$8($5,$7)/o;
		} elsif ( is_reg($2) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/($z2$5z3$7)$8(,$2,$3)/o;
		} elsif ( is_reg($3) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/($z2$5z3$7)$8(,$3,$2)/o;
		} elsif ( is_reg($5) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/($z1$2*$3$z3$7)$8($5)/o;
		} elsif ( is_reg($7) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/($z1$2*$3$z2$5)$8($7)/o;
		} else {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/($z1$2*$3$z2$5$z3$7)$8(,1)/o;
		}
	}
	elsif ( $par =~  /\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]/o ) {
		$a1 = $1;
		$a2 = $3;
		$a3 = $5;
		$z1 = bezplusa($a1);
		$z2 = bezplusa($a2);
		$z3 = bezplusa($a3);
		if ( is_reg($2) && is_reg($4) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]/($z3$6*$7)$8($2,$4)/o;
		} elsif ( is_reg($2) && is_reg($6) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]/($z2$4)$8($2,$6,$7)/o;
		} elsif ( is_reg($2) && is_reg($7) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]/($z2$4)$8($2,$7,$6)/o;
		} elsif ( is_reg($4) && is_reg($6) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]/($z1$2)$8($4,$6,$7)/o;
		} elsif ( is_reg($4) && is_reg($7) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]/($z1$2)$8($4,$7,$6)/o;
		} elsif ( is_reg($2) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]/($z2$4$z3$6*$7)$8($2)/o;
		} elsif ( is_reg($4) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]/($z3$6*$7$z1$2)$8($4)/o;
		} elsif ( is_reg($6) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]/($z1$2$z2$4)$8(,$6,$7)/o;
		} elsif ( is_reg($7) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]/($z1$2$z2$4)$8(,$7,$6)/o;
		} else {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]/($z1$2$z2$4$z3$6*$7)$8(,1)/o;
		}
	}
	elsif ( $par =~  /\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/o ) {
		$a1 = $1;
		$a2 = $3;
		$a3 = $5;
		$z1 = bezplusa($a1);
		$z2 = bezplusa($a2);
		$z3 = bezplusa($a3);
		if ( is_reg($2) && is_reg($4) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/($z3$6)$7($2,$4)/o;
		} elsif ( is_reg($2) && is_reg($6) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/($z2$4)$7($2,$6)/o;
		} elsif ( is_reg($4) && is_reg($6) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/($z1$2)$7($4,$6)/o;
		} elsif ( is_reg($2) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/($z3$6$z2$4)$7($2)/o;
		} elsif ( is_reg($4) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/($z3$6+$z1$2)$7($4)/o;
		} elsif ( is_reg($6) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/($z1$2$z2$4)$7($6)/o;
		} else {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/($z1$2$z2$4$z3$6)$7(,1)/o;
		}
	}
	elsif ( $par =~  /\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]/o ) {
		$a1 = $1;
		$a2 = $3;
		$z1 = bezplusa($a1);
		$z2 = bezplusa($a2);
		if ( is_reg($2) && is_reg($4) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]/($2,$4,$5)/o;
		} elsif ( is_reg($2) && is_reg($5) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]/($2,$5,$4)/o;
		} elsif ( is_reg($2) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]/($z2$4*$5)$6($2)/o;
		} elsif ( is_reg($4) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]/($z1$2)$6(,$4,$5)/o;
		} elsif ( is_reg($5) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]/($z1$2)$6(,$5,$4)/o;
		} else {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*\*\s*(\w+)\s*(\)*)\s*\]/($z1$2$z2$4*$5)$6(,1)/o;
		}
	}
	elsif ( $par =~  /\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/o ) {
		$a1 = $1;
		$a2 = $3;
		$z1 = bezplusa($a1);
		$z2 = bezplusa($a2);
		if ( is_reg($2) && is_reg($4) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/($2,$4)/o;
		} elsif ( is_reg($2) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/($z2$4)$5($2)/o;
		} elsif ( is_reg($4) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/($z1$2)$5($4)/o;
		} else {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/($2$z2$4)$5(,1)/o;
		}
	}
	elsif ( $par =~  /\[\s*(\w+)\s*\]/o ) {
		if ( is_reg($1) ) {
			# disp(base)
			$par =~ s/\[\s*(\w+)\s*\]/($1)/o;
		} else {
			$par =~ s/\[\s*(\w+)\s*\]/$1(,1)/o;
		}
	}
	elsif ( $par =~  /\[\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/o ) {
		$a1 = $1;
		$a2 = $4;
		$z1 = bezplusa($a1);
		$z2 = bezplusa($a2);
		if ( is_reg($2) && is_reg($5) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/($5,$2,$3)/o;
		} elsif ( is_reg($3) && is_reg($5) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/($5,$3,$2)/o;
		} elsif ( is_reg($2) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/($z2$5)$6(,$2,$3)/o;
		} elsif ( is_reg($3) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/($z2$5)$6(,$3,$2)/o;
		} elsif ( is_reg($5) ) {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/($z1$2*$3)$6($5)/o;
		} else {
			$par =~ s/\[\s*([\+\-\(\)]*)\s*(\w+)\s*\*\s*(\w+)\s*([\+\-\(\)]+)\s*(\w+)\s*(\)*)\s*\]/($z1$2*$3$z2$5)$6(,1)/o;
		}
	}
	foreach my $i (@regs_intel) {
		$par =~ s/\b($i)\b/%$1/;
	}

	return $par;
}

=head2 conv_att_instr_to_intel

 Converts the given string representing a valid AT&T instruction to Intel syntax.
 Returns the resulting string.

=cut

sub conv_att_instr_to_intel($) {

	my $par = shift;
	# (changing "xxx" to "[xxx]", if there's no '$' or '%')

	# (elements of memory operands mustn't be taken as instruction operands, so there are no '()'s here)
	if ( $par =~ /^\s*(\w+)\s+([\$\%\w\+\-]+)\s*,\s*([\$\%\w\+\-]+)\s*,\s*([\$\%\w\+\-]+)/o ) {

		my ($a1, $a2, $a3, $a4);

		$a1 = $1;
		$a2 = $2;
		$a3 = $3;
		$a4 = $4;

		# (don't touch "call/jmp xxx")
		if ( $a1 !~ /call/io && $a1 !~ /^\s*j[a-z]{1,3}/io ) {

			# (we mustn't change digits and %st(n))
			if ( $a2 !~ /\$/o && $a2 !~ /\%/o && $a2 !~ /_L\d+/o && $a2 =~ /[a-zA-Z_\.]/o ) {

				$a2 = "[$a2]";
			}
			if ( $a3 !~ /\$/o && $a3 !~ /\%/o && $a3 !~ /_L\d+/o && $a3 =~ /[a-zA-Z_\.]/o ) {

				$a3 = "[$a3]";
			}
			if ( $a4 !~ /\$/o && $a4 !~ /\%/o && $a4 !~ /_L\d+/o && $a4 =~ /[a-zA-Z_\.]/o ) {

				$a4 = "[$a4]";
			}

			# (ATTENTION: operand order will be changed later)
			$par = "\t$a1\t$a2, $a3, $a4\n";
		}
	}

	if ( $par =~ /^\s*(\w+)\s+([\$\%\w\+\-]+)\s*,\s*([\$\%\w\+\-]+)\s*$/o ) {

		my ($a1, $a2, $a3);

		$a1 = $1;
		$a2 = $2;
		$a3 = $3;

		# (don't touch "call/jmp xxx")
		if ( $a1 !~ /call/io && $a1 !~ /^\s*j[a-z]{1,3}/io ) {

			# (we mustn't change digits and %st(n))
			if ( $a2 !~ /\$/o && $a2 !~ /\%/o && $a2 !~ /_L\d+/o && $a2 =~ /[a-zA-Z_\.]/o ) {

				$a2 = "[$a2]";
			}
			if ( $a3 !~ /\$/o && $a3 !~ /\%/o && $a3 !~ /_L\d+/o && $a3 =~ /[a-zA-Z_\.]/o ) {

				$a3 = "[$a3]";
			}

			# (ATTENTION: operand order will be changed later)
			$par = "\t$a1\t$a2, $a3\n";
		}
	}

	if ( $par =~ /^\s*(\w+)\s+([\$\%\w\+\-]+)\s*\s*$/o ) {

		my ($a1, $a2);

		$a1 = $1;
		$a2 = $2;

		# (don't touch "call/jmp xxx")
		if ( $a1 !~ /call/io && $a1 !~ /^\s*j[a-z]{1,3}/io ) {

			# (we mustn't change digits and %st(n))
			if ( $a2 !~ /\$/o && $a2 !~ /\%/o && $a2 !~ /_L\d+/o && $a2 =~ /[a-zA-Z_\.]/o ) {

				$a2 = "[$a2]";
			}

			# (ATTENTION: operand order will be changed later)
			$par = "\t$a1\t$a2\n";
		}
	}

	# (removing dollar chars)
	$par =~ s/\$//go;
	# (removing percent chars)
	$par =~ s/%//go;
	# (removing asterisk chars)
	$par =~ s/\*//go;

	# (changing memory references):
	$par = conv_att_addr_to_intel $par;

	# (changing "st[N]" to "stN")
	$par =~ s/(\s)st\[(\d)\]/$1 st$2/go;
	# (changing "st" to "st0")
	$par =~ s/(\s)st(\s|,)/$1 st0$2/go;


	# (changing operands' order):
	if ( $par =~  /^\s*(\w+)\s+(\[?[:\.\w\*\+\-\(\)]+\]?)\s*,\s*(\[?[:\.\w\*\+\-\(\)]+\]?)\s*,\s*(\[?[:\.\w\*\+\-\(\)]+\]?)/o ) {
		if ( is_instr($1) ) {
			$par =~ s/^\s*(\w+)\s+(\[?[:\.\w\*\+\-\(\)]+\]?)\s*,\s*(\[?[:\.\w\*\+\-\(\)]+\]?)\s*,\s*(\[?[:\.\w\*\+\-\(\)]+\]?)/\t$1\t$4, $3, $2/o;
		}
	}
	if ( $par =~  /^\s*(\w+)\s+(\[?[:\.\w\*\+\-\(\)]+\]?)\s*,\s*(\[?[:\.\w\*\+\-\(\)]+\]?)([^,]*(;.*)?)$/o ) {
		if ( is_instr($1) ) {
			$par =~ s/^\s*(\w+)\s+(\[?[:\.\w\*\+\-\(\)]+\]?)\s*,\s*(\[?[:\.\w\*\+\-\(\)]+\]?)([^,]*(;.*)?)$/\t$1\t$3, $2$4/o;
		}
	}
	if ( $par =~  /^\s*(\w+)\s+(\[?[:\.\w\*\+\-\(\)]+\]?)([^,]*(;.*)?)$/o ) {
		if ( is_instr($1) ) {
			$par =~ s/^\s*(\w+)\s+(\[?[:\.\w\*\+\-\(\)]+\]?)([^,]*(;.*)?)$/\t$1\t$2$3/o;
		}
	}

	foreach my $i (@instr) {

		$par =~ s/^\s*$i[b]\s*(.*)$/\t$i\tbyte $1/i;
		$par =~ s/^\s*$i[w]\s*(.*)$/\t$i\tword $1/i;
		$par =~ s/^\s*$i[l]\s*(.*)$/\t$i\tdword $1/i;
	}

	$par =~ s/^\s*movsbw\s+(.*)\s*,\s*(.*)$/\tmovsx\t$1, byte $2\n/io;
	$par =~ s/^\s*movsbl\s+(.*)\s*,\s*(.*)$/\tmovsx\t$1, byte $2\n/io;
	$par =~ s/^\s*movswl\s+(.*)\s*,\s*(.*)$/\tmovsx\t$1, word $2\n/io;
	$par =~ s/^\s*movzbw\s+(.*)\s*,\s*(.*)$/\tmovzx\t$1, byte $2\n/io;
	$par =~ s/^\s*movzbl\s+(.*)\s*,\s*(.*)$/\tmovzx\t$1, byte $2\n/io;
	$par =~ s/^\s*movzwl\s+(.*)\s*,\s*(.*)$/\tmovzx\t$1, word $2\n/io;

	$par =~ s/^\s*l?(jmp|call)\s*(\[[\w\*\+\-\s]+\])/\t$1\tdword $2/io;
	$par =~ s/^\s*l?(jmp|call)\s*([\w\*\+\-]+)/\t$1\tdword $2/io;
	$par =~ s/^\s*l?(jmp|call)\s*(\w+)\s*,\s*(\w+)/\t$1\t$2:$3/io;
	$par =~ s/^\s*lret\s*(.*)$/\tret\t$1\t/i;

	$par =~ s/^\s*cbtw\s*/\tcbw\t/io;
	$par =~ s/^\s*cwtl\s*/\tcwde\t/io;
	$par =~ s/^\s*cwtd\s*/\tcwd\t/io;
	$par =~ s/^\s*cltd\s*/\tcdq\t/io;

	$par =~ s/^\s*f(\w+)s\s+(.*)$/\tf$1\tdword $2/io unless $par =~ /fchs\s/io;
	$par =~ s/^\s*f(\w+)l\s+(.*)$/\tf$1\tqword $2/io unless $par =~ /fmul\s/io;
	$par =~ s/^\s*f(\w+)q\s+(.*)$/\tf$1\tqword $2/io;
	$par =~ s/^\s*f(\w+)t\s+(.*)$/\tf$1\ttword $2/io unless $par =~ /fst\s/io;

	# (REP**: removing the end of line char)
	$par =~ s/^\s*(rep[enz]{0,2})\s*/\t$1/io;

	return $par;
}

=head2 conv_intel_instr_to_att

 Converts the given string representing a valid Intel instruction to AT&T syntax.
 Returns the resulting string.

=cut

sub conv_intel_instr_to_att($) {

	my $par = shift;
	my ($a1, $a2, $a3, $a4);
	$par =~ s/ptr//gi;

	# (add the suffix)
	foreach my $i (@att_suff_instr) {

		if ( $par =~ /^\s*$i\s+([^,]+)/i ) {

			($a1 = $1) =~ s/\s+$//o;
			if ( $par =~ /[^;]+\bbyte\b/io )     { $par =~ s/^\s*$i\s+byte\b/\t${i}b/i; }
			elsif ( $par =~ /[^;]+\bword\b/io )  { $par =~ s/^\s*$i\s+word\b/\t${i}w/i; }
			elsif ( $par =~ /[^;]+\bdword\b/io ) { $par =~ s/^\s*$i\s+dword\b/\t${i}l/i; }
			elsif ( $par =~ /^\s*$i\s+([^,]+)\s*,\s*([^,]+)/i ) {

				($a2 = $2) =~ s/\s+$//o;
				if ( $a2 !~ /\[.*\]/o ) {

					if ( is_reg8 ($a2) )    { $par =~ s/^\s*$i\b/\t${i}b/i; }
					elsif ( is_reg16($a2) ) { $par =~ s/^\s*$i\b/\t${i}w/i; }
					elsif ( is_reg32($a2) ) { $par =~ s/^\s*$i\b/\t${i}l/i; }
					elsif ( $par =~ /^\s*$i\s+([^\[\],]+)\s*,\s*([^,]+)/i ) {
						$a1 = $1;
						$a2 = $2;
						$a1 =~ s/\s+$//o;
						$a2 =~ s/\s+$//o;
						if ( is_reg8 ($a1) )    { $par =~ s/^\s*$i\b/\t${i}b/i; }
						elsif ( is_reg16($a1) ) { $par =~ s/^\s*$i\b/\t${i}w/i; }
						elsif ( is_reg32($a1) ) { $par =~ s/^\s*$i\b/\t${i}l/i; }
						else { $par =~ s/^\s*$i\b/\t${i}l/i; }
					}
				} elsif ( $par =~ /^\s*$i\s+([^\[\],]+)\s*,\s*([^,]+)/i ) {

					$a1 = $1;
					$a2 = $2;
					$a1 =~ s/\s+$//o;
					$a2 =~ s/\s+$//o;
					if ( is_reg8 ($a1) )    { $par =~ s/^\s*$i\b/\t${i}b/i; }
					elsif ( is_reg16($a1) ) { $par =~ s/^\s*$i\b/\t${i}w/i; }
					elsif ( is_reg32($a1) ) { $par =~ s/^\s*$i\b/\t${i}l/i; }
					else { $par =~ s/^\s*$i\b/\t${i}l/i; }
				} else {
					# (default: long)
					$par =~ s/^\s*$i\b/\t${i}l/i;
				}
			} else {
				# (default: long)
				$par =~ s/^\s*$i\b/\t${i}l/i;
			}
			last;
		}
	}

	# (changing operands' order):
	if ( $par =~ 	 /^\s*(\w+)\s+(\[?[:\.\w\*\+\-\s\(\)]+\]?)\s*,\s*(\[?[:\.\w\*\+\-\s\(\)]+\]?)\s*,\s*(\[?[:\.\w\*\+\-\s\(\)]+\]?)/o ) {
		if ( is_instr($1) ) {
			$par =~ s/^\s*(\w+)\s+(\[?[:\.\w\*\+\-\s\(\)]+\]?)\s*,\s*(\[?[:\.\w\*\+\-\s\(\)]+\]?)\s*,\s*(\[?[:\.\w\*\+\-\s\(\)]+\]?)/\t$1\t$4, $3, $2/o;
		}
	}
	if ( $par =~ 	 /^\s*(\w+)\s+(\[?[:\.\w\*\+\-\s\(\)]+\]?)\s*,\s*(\[?[:\.\w\*\+\-\s\(\)]+\]?)([^,]*(;.*)?)$/o ) {
		if ( is_instr($1) ) {
			$par =~ s/^\s*(\w+)\s+(\[?[:\.\w\*\+\-\s\(\)]+\]?)\s*,\s*(\[?[:\.\w\*\+\-\s\(\)]+\]?)([^,]*(;.*)?)$/\t$1\t$3, $2$4\n/o;
		}
	}
	if ( $par =~ 	 /^\s*(\w+)\s+(\[?[:\.\w\*\+\-\s\(\)]+\]?)([^,]*(;.*)?)$/o ) {
		if ( is_instr($1) ) {
			$par =~ s/^\s*(\w+)\s+(\[?[:\.\w\*\+\-\s\(\)]+\]?)([^,]*(;.*)?)$/\t$1\t$2$3\n/o;
		}
	}

	if ( $par =~ 	 /^\s*(\w+)\s+((t?byte|[dqpft]?word)\s*\[?[\.\w\*\+\-\s\(\)]+\]?)\s*,\s*(\[?[\.\w\*\+\-\s\(\)]+\]?)\s*,\s*(\[?[\.\w\*\+\-\s\(\)]+\]?)/o ) {
		if ( is_instr($1) ) {
			$par =~ s/^\s*(\w+)\s+((t?byte|[dqpft]?word)\s*\[?[\.\w\*\+\-\s\(\)]+\]?)\s*,\s*(\[?[\.\w\*\+\-\s\(\)]+\]?)\s*,\s*(\[?[\.\w\*\+\-\s\(\)]+\]?)/\t$1\t$5, $4, $2/o;
		}
	}
	if ( $par =~ 	 /^\s*(\w+)\s+((t?byte|[dqpft]?word)\s*\[?[\.\w\*\+\-\s\(\)]+\]?)\s*,\s*(\[?[\.\w\*\+\-\s\(\)]+\]?)([^,]*(;.*)?)$/o ) {
		if ( is_instr($1) ) {
			$par =~ s/^\s*(\w+)\s+((t?byte|[dqpft]?word)\s*\[?[\.\w\*\+\-\s\(\)]+\]?)\s*,\s*(\[?[\.\w\*\+\-\s\(\)]+\]?)([^,]*(;.*)?)$/\t$1\t$4, $2$5\n/o;
		}
	}
	if ( $par =~ 	 /^\s*(\w+)\s+((t?byte|[dqpft]?word)\s*\[?[\.\w\*\+\-\s\(\)]+\]?)([^,]*(;.*)?)$/o ) {
		if ( is_instr($1) ) {
			$par =~ s/^\s*(\w+)\s+((t?byte|[dqpft]?word)\s*\[?[\.\w\*\+\-\s\(\)]+\]?)([^,]*(;.*)?)$/\t$1\t$2$4\n/o;
		}
	}

	# (FPU instructions)
	$par =~ s/^\s*fi(\w+)\s+word\s*(.*)/\tfi${1}s\t$2/io;
	$par =~ s/^\s*fi(\w+)\s+dword\s*(.*)/\tfi${1}l\t$2/io;
	$par =~ s/^\s*fi(\w+)\s+qword\s*(.*)/\tfi${1}q\t$2/io;

	$par =~ s/^\s*f([^iI]\w+)\s+dword\s*(.*)/\tf${1}s\t$2/io;
	$par =~ s/^\s*f([^iI]\w+)\s+qword\s*(.*)/\tf${1}l\t$2/io;
	$par =~ s/^\s*f([^iI]\w+)\s+t(word|byte)\s*(.*)/\tf${1}t\t$3/io;

	# (change "xxx" to "$xxx", if there are no "[]")
	# (don't touch "call/jmp xxx")
	if ( $par !~ /^\s*(j[a-z]+|call)/io ) {

		if ( $par =~ /^\s*(\w+)\s+([^,]+)\s*,\s*([^,]+)\s*,\s*([^,]+)\s*/gio ) {


			$a1 = $1;
			$a2 = $2;
			$a3 = $3;
			$a4 = $4;
			$a1 =~ s/\s+$//o;
			$a2 =~ s/\s+$//o;
			$a3 =~ s/\s+$//o;
			$a4 =~ s/\s+$//o;
			$a2 =~ s/(t?byte|[dqpft]?word)//o;
			$a3 =~ s/(t?byte|[dqpft]?word)//o;
			$a4 =~ s/(t?byte|[dqpft]?word)//o;
			$a2 =~ s/^\s+//o;
			$a3 =~ s/^\s+//o;
			$a4 =~ s/^\s+//o;

			if ( $a2 !~ /\[/o && !is_reg($a2) ) { $a2 = "\$$a2"; }
			if ( $a3 !~ /\[/o && !is_reg($a3) ) { $a3 = "\$$a3"; }
			if ( $a4 !~ /\[/o && !is_reg($a4) ) { $a4 = "\$$a4"; }

			$par = "\t$a1\t$a2, $a3, $a4\n";

		} elsif ( $par =~ /^\s*(\w+)\s+([^,]+)\s*,\s*([^,]+)\s*/gio ) {

			$a1 = $1;
			$a2 = $2;
			$a3 = $3;
			$a1 =~ s/\s+$//o;
			$a2 =~ s/\s+$//o;
			$a3 =~ s/\s+$//o;
			$a2 =~ s/(t?byte|[dqpft]?word)//o;
			$a3 =~ s/(t?byte|[dqpft]?word)//o;
			$a2 =~ s/^\s+//o;
			$a3 =~ s/^\s+//o;

			if ( $a2 !~ /\[/o && !is_reg($a2) ) { $a2 = "\$$a2"; }
			if ( $a3 !~ /\[/o && !is_reg($a3) ) { $a3 = "\$$a3"; }

			$par = "\t$a1\t$a2, $a3\n";

		} elsif ( $par =~ /^\s*(\w+)\s+([^,]+)\s*/gio ) {

			$a1 = $1;
			$a2 = $2;
			$a1 =~ s/\s+$//o;
			$a2 =~ s/\s+$//o;
			$a2 =~ s/(t?byte|[dqpft]?word)//o;
			$a2 =~ s/^\s+//o;

			if ( $a2 !~ /\[/o && !is_reg($a2) ) { $a2 = "\$$a2"; }

			$par = "\t$a1\t$a2\n";

		}
	}

	my ($z1, $z2, $z3);
	# (add suffixes to MOVSX/MOVZX instructions)
	if ( $par =~ /^\s*(mov[sz])x\s+([^,]+)\s*,\s*([^,]+)(.*)/io ) {

		my ($inst, $arg1, $arg2, $reszta);
		$inst = $1;
		$z1 = $2;
		$z2 = $3;
		$reszta = $4;
		($arg1 = $z1) =~ s/\s*$//o;
		($arg2 = $z2) =~ s/\s*$//o;
		if ( ($par =~ /\bbyte\b/io || is_reg8($arg2) ) && is_reg32($arg1) ) {
			$par = "\t${inst}bl\t$arg1, $arg2 $reszta\n";
		} elsif ( ($par =~ /\bbyte\b/io || is_reg8($arg2) ) && is_reg16($arg1) ) {
			$par = "\t${inst}bw\t$arg1, $arg2 $reszta\n";
		} elsif ( $par =~ /\bword\b/io || is_reg16($arg2) || is_reg32($arg1)  ) {
			$par = "\t${inst}wl\t$arg1, $arg2 $reszta\n";
		}
	}

	$par =~ s/^\s*cbw\b/\tcbtw/io;
	$par =~ s/^\s*cwde\b/\tcwtl/io;
	$par =~ s/^\s*cwd\b/\tcwtd/io;
	$par =~ s/^\s*cdq\b/\tcltd/io;

	# (adding asterisk chars)
	$par =~ s/^\s*(jmp|call)\s+([dp]word|word|near|far|short)?\s*(\[[\w\*\+\-\s]+\])/\t$1\t*$3/io;
	$par =~ s/^\s*(jmp|call)\s+([dp]word|word|near|far|short)?\s*((0x)?\d+h?)/\t$1\t*$3/io;
	$par =~ s/^\s*(jmp|call)\s+([dp]word|word|near|far|short)?\s*([\w\*\+\-\s]+)/\t$1\t$3/io;
	$par =~ s/^\s*(jmp|call)\s+([^:]+)\s*:\s*([^:]+)/\tl$1\t$2, $3/io;
	$par =~ s/^\s*retf\s+(.*)$/\tlret\t$1/io;

	# (changing memory references):
	$par = conv_intel_addr_to_att $par;

	# (changing "stN" to "st(N)")
	$par =~ s/\bst(\d)\b/\%st($1)/go;


	# (adding percent chars)
	foreach my $r (@regs_intel) {

		$par =~ s/\b$r\b/\%$r/gi;
	}
	$par =~ s/\%\%/\%/gio;

	# (REP**: adding the end of line char)
	$par =~ s/^\s*(rep[enz]{0,2})\s+/\t$1\n\t/io;

	return $par;
}

=head1 SUPPORT AND DOCUMENTATION

After installing, you can find documentation for this module with the perldoc command.

    perldoc Asm::X86

You can also look for information at:

    Search CPAN
        http://search.cpan.org/dist/Asm-X86

    CPAN Request Tracker:
        http://rt.cpan.org/NoAuth/Bugs.html?Dist=Asm-X86

    AnnoCPAN, annotated CPAN documentation:
        http://annocpan.org/dist/Asm-X86

    CPAN Ratings:
        http://cpanratings.perl.org/d/Asm-X86

=head1 AUTHOR

Bogdan Drozdowski, C<< <bogdandr at op.pl> >>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Bogdan Drozdowski, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of Asm::X86