-- Copyright 2021 SmartThings
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local capabilities = require "st.capabilities"
local zcl_clusters = require "st.zigbee.zcl.clusters"
local battery_defaults = require "st.zigbee.defaults.battery_defaults"
local OccupancySensing = zcl_clusters.OccupancySensing

--module emit signal metrics
local signal = require "signal-metrics"

local ZIGBEE_IRIS_MOTION_SENSOR_FINGERPRINTS = {
    { mfr = "iMagic by GreatStar", model = "1117-S" }
}

local is_zigbee_iris_motion_sensor = function(opts, driver, device)
    for _, fingerprint in ipairs(ZIGBEE_IRIS_MOTION_SENSOR_FINGERPRINTS) do
        if device:get_manufacturer() == fingerprint.mfr and device:get_model() == fingerprint.model then
            return true
        end
    end
    return false
end

 ----- temperatre attribute configure ------
--local tempMeasurement = zcl_clusters.TemperatureMeasurement
--local device_management = require "st.zigbee.device_management"
--local tempMeasurement_defaults = require "st.zigbee.defaults.temperatureMeasurement_defaults"

local function do_configure(self,device)
    print ("subdriver do_configure")
    local maxTime = device.preferences.maxTime * 60
    local changeRep = device.preferences.changeRep
    print ("maxTime y changeRep: ",maxTime, changeRep )
      device:send(device_management.build_bind_request(device, tempMeasurement.ID, self.environment_info.hub_zigbee_eui))
      device:send(tempMeasurement.attributes.MeasuredValue:configure_reporting(device, 30, maxTime, changeRep))
      device:configure()
  end
 

  local function temp_attr_handler(self, device, tempvalue, zb_rx)
    -- emit signal metrics
    signal.metrics(device, zb_rx)

    tempMeasurement_defaults.temp_attr_handler(self, device, tempvalue, zb_rx)
  end

local iris_motion_handler = {
    NAME = "Iris Motion Handler",
    lifecycle_handlers = {
        --init = battery_defaults.build_linear_voltage_init(2.4, 2.7),
        --doConfigure = do_configure
    },
    zigbee_handlers = {
        attr = {
          --[tempMeasurement.ID] = {
              --[tempMeasurement.attributes.MeasuredValue.ID] = temp_attr_handler
          --}
        }
      },
    can_handle = is_zigbee_iris_motion_sensor
}

return iris_motion_handler
