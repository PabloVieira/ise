/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                       */
/*  \   \        Copyright (c) 2003-2009 Xilinx, Inc.                */
/*  /   /          All Right Reserved.                                 */
/* /---/   /\                                                         */
/* \   \  /  \                                                      */
/*  \___\/\___\                                                    */
/***********************************************************************/

/* This file is designed for use with ISim build 0x7708f090 */

#define XSI_HIDE_SYMBOL_SPEC true
#include "xsi.h"
#include <memory.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
static const char *ng0 = "C:/Users/Pablo/Documents/arqi/ise/tp2/MIPS-MC_SingleEdge_tb.vhd";
extern char *IEEE_P_3620187407;
extern char *WORK_P_2180760208;

char *ieee_p_3620187407_sub_436279890_3965413181(char *, char *, char *, char *, int );
int ieee_p_3620187407_sub_514432868_3965413181(char *, char *, char *);
char *ieee_p_3620187407_sub_767740470_3965413181(char *, char *, char *, char *, char *, char *);


static void work_a_4249212076_3836892431_p_0(char *t0)
{
    char t1[16];
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    char *t7;
    char *t8;
    char *t9;
    unsigned int t10;
    unsigned int t11;
    unsigned char t12;
    char *t13;
    char *t14;
    char *t15;
    char *t16;
    char *t17;
    char *t18;

LAB0:    xsi_set_current_line(142, ng0);

LAB3:    t2 = (t0 + 1672U);
    t3 = *((char **)t2);
    t2 = (t0 + 1680U);
    t4 = *((char **)t2);
    t5 = (t0 + 23352);
    t7 = (t0 + 2456);
    t7 = *((char **)t7);
    t8 = ieee_p_3620187407_sub_767740470_3965413181(IEEE_P_3620187407, t1, t3, t4, t5, t7);
    t9 = (t1 + 12U);
    t10 = *((unsigned int *)t9);
    t11 = (1U * t10);
    t12 = (32U != t11);
    if (t12 == 1)
        goto LAB5;

LAB6:    t13 = (t0 + 4360);
    t14 = (t13 + 56U);
    t15 = *((char **)t14);
    t16 = (t15 + 56U);
    t17 = *((char **)t16);
    memcpy(t17, t8, 32U);
    xsi_driver_first_trans_fast(t13);

LAB2:    t18 = (t0 + 4248);
    *((int *)t18) = 1;

LAB1:    return;
LAB4:    goto LAB2;

LAB5:    xsi_size_not_matching(32U, t11, 0);
    goto LAB6;

}

static void work_a_4249212076_3836892431_p_1(char *t0)
{
    char t36[16];
    unsigned char t1;
    char *t2;
    char *t3;
    unsigned char t4;
    unsigned char t5;
    char *t6;
    unsigned char t7;
    unsigned char t8;
    unsigned char t9;
    char *t10;
    unsigned int t11;
    unsigned int t12;
    unsigned int t13;
    char *t14;
    int t15;
    unsigned char t16;
    char *t17;
    char *t18;
    unsigned int t19;
    unsigned int t20;
    unsigned int t21;
    char *t22;
    int t23;
    char *t24;
    char *t25;
    int t26;
    int t27;
    unsigned char t28;
    char *t29;
    unsigned char t30;
    unsigned char t31;
    char *t32;
    unsigned int t33;
    unsigned int t34;
    unsigned int t35;
    char *t37;
    char *t38;
    unsigned int t39;
    unsigned int t40;
    unsigned int t41;
    char *t42;
    char *t43;
    int t44;
    int t45;
    unsigned int t46;
    unsigned int t47;
    unsigned int t48;
    char *t49;
    char *t50;
    char *t51;
    char *t52;
    char *t53;

LAB0:    xsi_set_current_line(147, ng0);
    t2 = (t0 + 1032U);
    t3 = *((char **)t2);
    t4 = *((unsigned char *)t3);
    t5 = (t4 == (unsigned char)2);
    if (t5 == 1)
        goto LAB5;

LAB6:    t1 = (unsigned char)0;

LAB7:    if (t1 != 0)
        goto LAB2;

LAB4:
LAB3:    t2 = (t0 + 4264);
    *((int *)t2) = 1;

LAB1:    return;
LAB2:    xsi_set_current_line(148, ng0);
    t2 = (t0 + 2152U);
    t10 = *((char **)t2);
    t11 = (31 - 15);
    t12 = (t11 * 1U);
    t13 = (0 + t12);
    t2 = (t10 + t13);
    t14 = (t0 + 6836U);
    t15 = ieee_p_3620187407_sub_514432868_3965413181(IEEE_P_3620187407, t2, t14);
    t16 = (t15 >= 0);
    if (t16 == 1)
        goto LAB11;

LAB12:    t9 = (unsigned char)0;

LAB13:    if (t9 != 0)
        goto LAB8;

LAB10:
LAB9:    goto LAB3;

LAB5:    t2 = (t0 + 1192U);
    t6 = *((char **)t2);
    t7 = *((unsigned char *)t6);
    t8 = (t7 == (unsigned char)2);
    t1 = t8;
    goto LAB7;

LAB8:    xsi_set_current_line(149, ng0);
    t24 = (t0 + 1512U);
    t29 = *((char **)t24);
    t30 = *((unsigned char *)t29);
    t31 = (t30 == (unsigned char)3);
    if (t31 != 0)
        goto LAB14;

LAB16:
LAB15:    xsi_set_current_line(154, ng0);
    t2 = (t0 + 1832U);
    t3 = *((char **)t2);
    t11 = (31 - 7);
    t12 = (t11 * 1U);
    t13 = (0 + t12);
    t2 = (t3 + t13);
    t6 = (t0 + 2152U);
    t10 = *((char **)t6);
    t19 = (31 - 15);
    t20 = (t19 * 1U);
    t21 = (0 + t20);
    t6 = (t10 + t21);
    t14 = (t0 + 6836U);
    t15 = ieee_p_3620187407_sub_514432868_3965413181(IEEE_P_3620187407, t6, t14);
    t23 = (t15 - 0);
    t33 = (t23 * 1);
    t34 = (8U * t33);
    t35 = (0U + t34);
    t17 = (t0 + 4424);
    t18 = (t17 + 56U);
    t22 = *((char **)t18);
    t24 = (t22 + 56U);
    t25 = *((char **)t24);
    memcpy(t25, t2, 8U);
    xsi_driver_first_trans_delta(t17, t35, 8U, 0LL);
    goto LAB9;

LAB11:    t17 = (t0 + 2152U);
    t18 = *((char **)t17);
    t19 = (31 - 15);
    t20 = (t19 * 1U);
    t21 = (0 + t20);
    t17 = (t18 + t21);
    t22 = (t0 + 6836U);
    t23 = ieee_p_3620187407_sub_514432868_3965413181(IEEE_P_3620187407, t17, t22);
    t24 = ((WORK_P_2180760208) + 1168U);
    t25 = *((char **)t24);
    t26 = *((int *)t25);
    t27 = (t26 - 3);
    t28 = (t23 <= t27);
    t9 = t28;
    goto LAB13;

LAB14:    xsi_set_current_line(150, ng0);
    t24 = (t0 + 1832U);
    t32 = *((char **)t24);
    t33 = (31 - 31);
    t34 = (t33 * 1U);
    t35 = (0 + t34);
    t24 = (t32 + t35);
    t37 = (t0 + 2152U);
    t38 = *((char **)t37);
    t39 = (31 - 15);
    t40 = (t39 * 1U);
    t41 = (0 + t40);
    t37 = (t38 + t41);
    t42 = (t0 + 6836U);
    t43 = ieee_p_3620187407_sub_436279890_3965413181(IEEE_P_3620187407, t36, t37, t42, 3);
    t44 = ieee_p_3620187407_sub_514432868_3965413181(IEEE_P_3620187407, t43, t36);
    t45 = (t44 - 0);
    t46 = (t45 * 1);
    t47 = (8U * t46);
    t48 = (0U + t47);
    t49 = (t0 + 4424);
    t50 = (t49 + 56U);
    t51 = *((char **)t50);
    t52 = (t51 + 56U);
    t53 = *((char **)t52);
    memcpy(t53, t24, 8U);
    xsi_driver_first_trans_delta(t49, t48, 8U, 0LL);
    xsi_set_current_line(151, ng0);
    t2 = (t0 + 1832U);
    t3 = *((char **)t2);
    t11 = (31 - 23);
    t12 = (t11 * 1U);
    t13 = (0 + t12);
    t2 = (t3 + t13);
    t6 = (t0 + 2152U);
    t10 = *((char **)t6);
    t19 = (31 - 15);
    t20 = (t19 * 1U);
    t21 = (0 + t20);
    t6 = (t10 + t21);
    t14 = (t0 + 6836U);
    t17 = ieee_p_3620187407_sub_436279890_3965413181(IEEE_P_3620187407, t36, t6, t14, 2);
    t15 = ieee_p_3620187407_sub_514432868_3965413181(IEEE_P_3620187407, t17, t36);
    t23 = (t15 - 0);
    t33 = (t23 * 1);
    t34 = (8U * t33);
    t35 = (0U + t34);
    t18 = (t0 + 4424);
    t22 = (t18 + 56U);
    t24 = *((char **)t22);
    t25 = (t24 + 56U);
    t29 = *((char **)t25);
    memcpy(t29, t2, 8U);
    xsi_driver_first_trans_delta(t18, t35, 8U, 0LL);
    xsi_set_current_line(152, ng0);
    t2 = (t0 + 1832U);
    t3 = *((char **)t2);
    t11 = (31 - 15);
    t12 = (t11 * 1U);
    t13 = (0 + t12);
    t2 = (t3 + t13);
    t6 = (t0 + 2152U);
    t10 = *((char **)t6);
    t19 = (31 - 15);
    t20 = (t19 * 1U);
    t21 = (0 + t20);
    t6 = (t10 + t21);
    t14 = (t0 + 6836U);
    t17 = ieee_p_3620187407_sub_436279890_3965413181(IEEE_P_3620187407, t36, t6, t14, 1);
    t15 = ieee_p_3620187407_sub_514432868_3965413181(IEEE_P_3620187407, t17, t36);
    t23 = (t15 - 0);
    t33 = (t23 * 1);
    t34 = (8U * t33);
    t35 = (0U + t34);
    t18 = (t0 + 4424);
    t22 = (t18 + 56U);
    t24 = *((char **)t22);
    t25 = (t24 + 56U);
    t29 = *((char **)t25);
    memcpy(t29, t2, 8U);
    xsi_driver_first_trans_delta(t18, t35, 8U, 0LL);
    goto LAB15;

}

static void work_a_4249212076_3836892431_p_2(char *t0)
{
    char t31[16];
    unsigned char t1;
    unsigned char t2;
    unsigned char t3;
    char *t4;
    char *t5;
    unsigned char t6;
    unsigned char t7;
    char *t8;
    unsigned char t9;
    unsigned char t10;
    char *t11;
    unsigned int t12;
    unsigned int t13;
    unsigned int t14;
    char *t15;
    int t16;
    unsigned char t17;
    char *t18;
    char *t19;
    unsigned int t20;
    unsigned int t21;
    unsigned int t22;
    char *t23;
    int t24;
    char *t25;
    char *t26;
    int t27;
    int t28;
    unsigned char t29;
    char *t30;
    char *t32;
    unsigned int t33;
    unsigned int t34;
    unsigned int t35;
    char *t36;
    char *t37;
    int t38;
    int t39;
    unsigned int t40;
    unsigned int t41;
    unsigned int t42;
    char *t43;
    char *t44;
    char *t45;
    char *t46;
    char *t47;
    char *t48;

LAB0:    xsi_set_current_line(162, ng0);
    t4 = (t0 + 1032U);
    t5 = *((char **)t4);
    t6 = *((unsigned char *)t5);
    t7 = (t6 == (unsigned char)2);
    if (t7 == 1)
        goto LAB11;

LAB12:    t3 = (unsigned char)0;

LAB13:    if (t3 == 1)
        goto LAB8;

LAB9:    t2 = (unsigned char)0;

LAB10:    if (t2 == 1)
        goto LAB5;

LAB6:    t1 = (unsigned char)0;

LAB7:    if (t1 != 0)
        goto LAB2;

LAB4:    xsi_set_current_line(169, ng0);
    t4 = xsi_get_transient_memory(8U);
    memset(t4, 0, 8U);
    t5 = t4;
    memset(t5, (unsigned char)4, 8U);
    t8 = (t0 + 4488);
    t11 = (t8 + 56U);
    t15 = *((char **)t11);
    t18 = (t15 + 56U);
    t19 = *((char **)t18);
    memcpy(t19, t4, 8U);
    xsi_driver_first_trans_delta(t8, 0U, 8U, 0LL);
    xsi_set_current_line(170, ng0);
    t4 = xsi_get_transient_memory(8U);
    memset(t4, 0, 8U);
    t5 = t4;
    memset(t5, (unsigned char)4, 8U);
    t8 = (t0 + 4488);
    t11 = (t8 + 56U);
    t15 = *((char **)t11);
    t18 = (t15 + 56U);
    t19 = *((char **)t18);
    memcpy(t19, t4, 8U);
    xsi_driver_first_trans_delta(t8, 8U, 8U, 0LL);
    xsi_set_current_line(171, ng0);
    t4 = xsi_get_transient_memory(8U);
    memset(t4, 0, 8U);
    t5 = t4;
    memset(t5, (unsigned char)4, 8U);
    t8 = (t0 + 4488);
    t11 = (t8 + 56U);
    t15 = *((char **)t11);
    t18 = (t15 + 56U);
    t19 = *((char **)t18);
    memcpy(t19, t4, 8U);
    xsi_driver_first_trans_delta(t8, 16U, 8U, 0LL);
    xsi_set_current_line(172, ng0);
    t4 = xsi_get_transient_memory(8U);
    memset(t4, 0, 8U);
    t5 = t4;
    memset(t5, (unsigned char)4, 8U);
    t8 = (t0 + 4488);
    t11 = (t8 + 56U);
    t15 = *((char **)t11);
    t18 = (t15 + 56U);
    t19 = *((char **)t18);
    memcpy(t19, t4, 8U);
    xsi_driver_first_trans_delta(t8, 24U, 8U, 0LL);

LAB3:    t4 = (t0 + 4280);
    *((int *)t4) = 1;

LAB1:    return;
LAB2:    xsi_set_current_line(164, ng0);
    t25 = (t0 + 1992U);
    t30 = *((char **)t25);
    t25 = (t0 + 2152U);
    t32 = *((char **)t25);
    t33 = (31 - 15);
    t34 = (t33 * 1U);
    t35 = (0 + t34);
    t25 = (t32 + t35);
    t36 = (t0 + 6836U);
    t37 = ieee_p_3620187407_sub_436279890_3965413181(IEEE_P_3620187407, t31, t25, t36, 3);
    t38 = ieee_p_3620187407_sub_514432868_3965413181(IEEE_P_3620187407, t37, t31);
    t39 = (t38 - 0);
    t40 = (t39 * 1);
    xsi_vhdl_check_range_of_index(0, 2048, 1, t38);
    t41 = (8U * t40);
    t42 = (0 + t41);
    t43 = (t30 + t42);
    t44 = (t0 + 4488);
    t45 = (t44 + 56U);
    t46 = *((char **)t45);
    t47 = (t46 + 56U);
    t48 = *((char **)t47);
    memcpy(t48, t43, 8U);
    xsi_driver_first_trans_delta(t44, 0U, 8U, 0LL);
    xsi_set_current_line(165, ng0);
    t4 = (t0 + 1992U);
    t5 = *((char **)t4);
    t4 = (t0 + 2152U);
    t8 = *((char **)t4);
    t12 = (31 - 15);
    t13 = (t12 * 1U);
    t14 = (0 + t13);
    t4 = (t8 + t14);
    t11 = (t0 + 6836U);
    t15 = ieee_p_3620187407_sub_436279890_3965413181(IEEE_P_3620187407, t31, t4, t11, 2);
    t16 = ieee_p_3620187407_sub_514432868_3965413181(IEEE_P_3620187407, t15, t31);
    t24 = (t16 - 0);
    t20 = (t24 * 1);
    xsi_vhdl_check_range_of_index(0, 2048, 1, t16);
    t21 = (8U * t20);
    t22 = (0 + t21);
    t18 = (t5 + t22);
    t19 = (t0 + 4488);
    t23 = (t19 + 56U);
    t25 = *((char **)t23);
    t26 = (t25 + 56U);
    t30 = *((char **)t26);
    memcpy(t30, t18, 8U);
    xsi_driver_first_trans_delta(t19, 8U, 8U, 0LL);
    xsi_set_current_line(166, ng0);
    t4 = (t0 + 1992U);
    t5 = *((char **)t4);
    t4 = (t0 + 2152U);
    t8 = *((char **)t4);
    t12 = (31 - 15);
    t13 = (t12 * 1U);
    t14 = (0 + t13);
    t4 = (t8 + t14);
    t11 = (t0 + 6836U);
    t15 = ieee_p_3620187407_sub_436279890_3965413181(IEEE_P_3620187407, t31, t4, t11, 1);
    t16 = ieee_p_3620187407_sub_514432868_3965413181(IEEE_P_3620187407, t15, t31);
    t24 = (t16 - 0);
    t20 = (t24 * 1);
    xsi_vhdl_check_range_of_index(0, 2048, 1, t16);
    t21 = (8U * t20);
    t22 = (0 + t21);
    t18 = (t5 + t22);
    t19 = (t0 + 4488);
    t23 = (t19 + 56U);
    t25 = *((char **)t23);
    t26 = (t25 + 56U);
    t30 = *((char **)t26);
    memcpy(t30, t18, 8U);
    xsi_driver_first_trans_delta(t19, 16U, 8U, 0LL);
    xsi_set_current_line(167, ng0);
    t4 = (t0 + 1992U);
    t5 = *((char **)t4);
    t4 = (t0 + 2152U);
    t8 = *((char **)t4);
    t12 = (31 - 15);
    t13 = (t12 * 1U);
    t14 = (0 + t13);
    t4 = (t8 + t14);
    t11 = (t0 + 6836U);
    t16 = ieee_p_3620187407_sub_514432868_3965413181(IEEE_P_3620187407, t4, t11);
    t24 = (t16 - 0);
    t20 = (t24 * 1);
    xsi_vhdl_check_range_of_index(0, 2048, 1, t16);
    t21 = (8U * t20);
    t22 = (0 + t21);
    t15 = (t5 + t22);
    t18 = (t0 + 4488);
    t19 = (t18 + 56U);
    t23 = *((char **)t19);
    t25 = (t23 + 56U);
    t26 = *((char **)t25);
    memcpy(t26, t15, 8U);
    xsi_driver_first_trans_delta(t18, 24U, 8U, 0LL);
    goto LAB3;

LAB5:    t18 = (t0 + 2152U);
    t19 = *((char **)t18);
    t20 = (31 - 15);
    t21 = (t20 * 1U);
    t22 = (0 + t21);
    t18 = (t19 + t22);
    t23 = (t0 + 6836U);
    t24 = ieee_p_3620187407_sub_514432868_3965413181(IEEE_P_3620187407, t18, t23);
    t25 = ((WORK_P_2180760208) + 1168U);
    t26 = *((char **)t25);
    t27 = *((int *)t26);
    t28 = (t27 - 3);
    t29 = (t24 <= t28);
    t1 = t29;
    goto LAB7;

LAB8:    t4 = (t0 + 2152U);
    t11 = *((char **)t4);
    t12 = (31 - 15);
    t13 = (t12 * 1U);
    t14 = (0 + t13);
    t4 = (t11 + t14);
    t15 = (t0 + 6836U);
    t16 = ieee_p_3620187407_sub_514432868_3965413181(IEEE_P_3620187407, t4, t15);
    t17 = (t16 >= 0);
    t2 = t17;
    goto LAB10;

LAB11:    t4 = (t0 + 1352U);
    t8 = *((char **)t4);
    t9 = *((unsigned char *)t8);
    t10 = (t9 == (unsigned char)2);
    t3 = t10;
    goto LAB13;

}


extern void work_a_4249212076_3836892431_init()
{
	static char *pe[] = {(void *)work_a_4249212076_3836892431_p_0,(void *)work_a_4249212076_3836892431_p_1,(void *)work_a_4249212076_3836892431_p_2};
	xsi_register_didat("work_a_4249212076_3836892431", "isim/CPU_tb_isim_beh.exe.sim/work/a_4249212076_3836892431.didat");
	xsi_register_executes(pe);
}
