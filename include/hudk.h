void __fastcall vdc_wait_vsync();

#define INT_IRQ2 (1<<0)
#define INT_IRQ1 (1<<1)
#define INT_TIMER (1<<2)
#define INT_NMI (1<<3)
#define INT_ALL (INT_IRQ2 | INT_IRQ1 | INT_TIMER | INT_NMI)

void __fastcall irq_enable(char c<acc>);
void __fastcall irq_disable(char c<acc>);


void __fastcall print_char(char c<acc>);
void __fastcall print_digit(char d<acc>);
void __fastcall print_hex(char h<acc>);
void __fastcall print_bcd(int n0<_ax>);
void __fastcall print_bcd(int n0<_ax>, int n1<_bx>);
void __fastcall print_dec_u8(char u8<acc>);
void __fastcall print_dec_u16(int u16<acc>);
void __fastcall print_hex_u8(char h8<acc>);
void __fastcall print_hex_u16(int h16<acc>);
void __fastcall print_string(char x<_cl>, char y<_ch>, char width<_al>, char height<_ah>, char *txt<_si>);
void __fastcall print_string_raw(char *txt<_si>);
void __fastcall print_string_n(char *txt<_si>, int count<acc>);
void __fastcall print_fill(char x<_cl>, char y<_ch>, char width<_al>, char height<_ah>, char c<_bl>);
