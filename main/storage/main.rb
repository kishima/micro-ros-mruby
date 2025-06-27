puts "start I2C control"

i2c = ESP32::I2C.new()
i2c.init(ESP32::I2C::PORT0, {sda: 0, scl: 26, freq: 400000})

# 0x20 : RGB LED color
# 0x50 : Joy Raw data
# 0x60 : Stick X,Y value (4)
#        Left X, Left Y, Right X, Right Y
# 0x64 : Button status
# 0x70 : Stick Angle value
# 0x74 : Stick Distance value

def i2c_read_8bit(m, reg_addr)
  result = m.read(0x38, reg_addr, 1)
  result ? result.bytes[0] : 0
end

# Wait for network to be ready
ESP32::System.delay(3000)

# init micro ROS
ESP32::MicroROS.init

# create Node
# register publisher

loop do
  stick_left_x = i2c_read_8bit(i2c, 0x60)
  stick_left_y = i2c_read_8bit(i2c, 0x61)
  stick_right_x = i2c_read_8bit(i2c, 0x62)
  stick_right_y = i2c_read_8bit(i2c, 0x63)
  puts "#{stick_left_x},#{stick_left_y},#{stick_right_x},#{stick_right_y}"

  #make joy topic
  lx = (stick_left_x - 100) / 100.0
  ly = (stick_left_y - 100) / 100.0

  #publish topic
  ESP32::MicroROS.publish( lx, ly )
  #spin
  ESP32::MicroROS.spin_some(100)

  ESP32::System.delay(100)
end

i2c.deinit
