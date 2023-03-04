typedef enum {ac_none, ac_and_md, ac_add_md, ac_zero, ac_uc, ac_iot} sel_ac_t;
typedef enum {pc_none, pc_data, pc_ma, pc_ma1, pc_incr} sel_pc_t;
typedef enum {skip_none, skip_md_clear, skip_uc, skip_iot} sel_skip_t;
typedef enum {addr_none, addr_ma, addr_pc, addr_ea} sel_addr_t;
typedef enum {data_none, data_ac, data_md, data_pc, data_pc1} sel_data_t;
typedef enum {iot_none, iot_en} sel_iot_t;
typedef enum {ir_none, ir_data} sel_ir_t;
typedef enum {ma_none, ma_data, ma_ea} sel_ma_t;
typedef enum {md_none, md_data, md_data1} sel_md_t;
