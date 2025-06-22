#include <string.h>
#include <stdio.h>
#include <unistd.h>

#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_log.h"
#include "esp_system.h"
#include "nvs_flash.h"
#include "esp_littlefs.h"

#include "mruby.h"
#include "mruby/irep.h"
#include "mruby/compile.h"
#include "mruby/error.h"
#include "mruby/string.h"
#include "mruby/dump.h"

#define TAG "mruby_task"

typedef mrb_value (*mrb_load_func)(mrb_state*, FILE*, mrbc_context*);

// #include <uros_network_interfaces.h>
// #include <rcl/rcl.h>
// #include <rcl/error_handling.h>
// #include <std_msgs/msg/int32.h>
// #include <rclc/rclc.h>
// #include <rclc/executor.h>

// #ifdef CONFIG_MICRO_ROS_ESP_XRCE_DDS_MIDDLEWARE
// #include <rmw_microros/rmw_microros.h>
// #endif




// #define RCCHECK(fn) { rcl_ret_t temp_rc = fn; if((temp_rc != RCL_RET_OK)){printf("Failed status on line %d: %d. Aborting.\n",__LINE__,(int)temp_rc);vTaskDelete(NULL);}}
// #define RCSOFTCHECK(fn) { rcl_ret_t temp_rc = fn; if((temp_rc != RCL_RET_OK)){printf("Failed status on line %d: %d. Continuing.\n",__LINE__,(int)temp_rc);}}

// rcl_publisher_t publisher;
// std_msgs__msg__Int32 msg;

// void timer_callback(rcl_timer_t * timer, int64_t last_call_time)
// {
// 	RCLC_UNUSED(last_call_time);
// 	if (timer != NULL) {
// 		printf("Publishing: %d\n", (int) msg.data);
// 		RCSOFTCHECK(rcl_publish(&publisher, &msg, NULL));
// 		msg.data++;
// 	}
// }

// void micro_ros_task(void * arg)
// {
// 	rcl_allocator_t allocator = rcl_get_default_allocator();
// 	rclc_support_t support;

// 	rcl_init_options_t init_options = rcl_get_zero_initialized_init_options();
// 	RCCHECK(rcl_init_options_init(&init_options, allocator));

// #ifdef CONFIG_MICRO_ROS_ESP_XRCE_DDS_MIDDLEWARE
// 	rmw_init_options_t* rmw_options = rcl_init_options_get_rmw_init_options(&init_options);

// 	// Static Agent IP and port can be used instead of autodisvery.
// 	RCCHECK(rmw_uros_options_set_udp_address(CONFIG_MICRO_ROS_AGENT_IP, CONFIG_MICRO_ROS_AGENT_PORT, rmw_options));
// 	//RCCHECK(rmw_uros_discover_agent(rmw_options));
// #endif

// 	// create init_options
// 	RCCHECK(rclc_support_init_with_options(&support, 0, NULL, &init_options, &allocator));

// 	// create node
// 	rcl_node_t node;
// 	RCCHECK(rclc_node_init_default(&node, "esp32_int32_publisher", "", &support));

// 	// create publisher
// 	RCCHECK(rclc_publisher_init_default(
// 		&publisher,
// 		&node,
// 		ROSIDL_GET_MSG_TYPE_SUPPORT(std_msgs, msg, Int32),
// 		"freertos_int32_publisher"));

// 	// create timer,
// 	rcl_timer_t timer;
// 	const unsigned int timer_timeout = 1000;
// 	RCCHECK(rclc_timer_init_default(
// 		&timer,
// 		&support,
// 		RCL_MS_TO_NS(timer_timeout),
// 		timer_callback));

// 	// create executor
// 	rclc_executor_t executor;
// 	RCCHECK(rclc_executor_init(&executor, &support.context, 1, &allocator));
// 	RCCHECK(rclc_executor_add_timer(&executor, &timer));

// 	msg.data = 0;

// 	while(1){
// 		rclc_executor_spin_some(&executor, RCL_MS_TO_NS(100));
// 		usleep(10000);
// 	}

// 	// free resources
// 	RCCHECK(rcl_publisher_fini(&publisher, &node));
// 	RCCHECK(rcl_node_fini(&node));

//   	vTaskDelete(NULL);
// }

// void app_main(void)
// {
// #if defined(CONFIG_MICRO_ROS_ESP_NETIF_WLAN) || defined(CONFIG_MICRO_ROS_ESP_NETIF_ENET)
//     ESP_ERROR_CHECK(uros_network_interface_initialize());
// #endif

//     //pin micro-ros task in APP_CPU to make PRO_CPU to deal with wifi:
//     xTaskCreate(micro_ros_task,
//             "uros_task",
//             CONFIG_MICRO_ROS_APP_STACK,
//             NULL,
//             CONFIG_MICRO_ROS_APP_TASK_PRIO,
//             NULL);
// }


void mruby_task(void *pvParameter)
{
  mrb_state *mrb = mrb_open();
  mrbc_context *context = mrbc_context_new(mrb);
  int ai = mrb_gc_arena_save(mrb);
  ESP_LOGI(TAG, "%s", "Loading...");

  mrb_load_func load = mrb_load_detect_file_cxt;
  FILE *fp = fopen("/storage/main.rb", "r");
  if (fp == NULL) {
    load = mrb_load_irep_file_cxt;
    fp = fopen("/storage/main.mrb", "r");
    if (fp == NULL) {
      ESP_LOGI(TAG, "File is none.");
      goto exit;
    }
  }
  load(mrb, fp, context);
  if (mrb->exc) {
    ESP_LOGE(TAG, "Exception occurred");
    mrb_print_error(mrb);
    mrb->exc = 0;
  } else {
    ESP_LOGI(TAG, "%s", "Success");
  }
  mrb_gc_arena_restore(mrb, ai);
  mrbc_context_free(mrb, context);
  mrb_close(mrb);
  fclose(fp);

  // This task should never end, even if the
  // script ends.
exit:
  while (1) {
    vTaskDelay(1);
  }
}

void app_main()
{
  nvs_flash_init();

  esp_vfs_littlefs_conf_t conf = {
    .base_path = "/storage",
    .partition_label = "storage",
    .format_if_mount_failed = false,
  };
  ESP_ERROR_CHECK(esp_vfs_littlefs_register(&conf));

  xTaskCreate(&mruby_task, "mruby_task", 16384, NULL, 5, NULL);
}
