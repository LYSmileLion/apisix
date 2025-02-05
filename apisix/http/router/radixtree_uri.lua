--
-- Licensed to the Apache Software Foundation (ASF) under one or more
-- contributor license agreements.  See the NOTICE file distributed with
-- this work for additional information regarding copyright ownership.
-- The ASF licenses this file to You under the Apache License, Version 2.0
-- (the "License"); you may not use this file except in compliance with
-- the License.  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.
--
local require = require
local core = require("apisix.core")
local base_router = require("apisix.http.route")
local get_services = require("apisix.http.service").services
local cached_router_version
local cached_service_version


local _M = {version = 0.2}


    local uri_routes = {}
    local uri_router
    local match_opts = {}
function _M.match(api_ctx)
    local user_routes = _M.user_routes --attach_http_router_common_methods中init函数执行时，会将/apisix/routes obj下的内容attach到该对象上
    local _, service_version = get_services()
    if not cached_router_version or cached_router_version ~= user_routes.conf_version
        or not cached_service_version or cached_service_version ~= service_version
    then
        uri_router = base_router.create_radixtree_uri_router(user_routes.values, --/routes 下面的路由数组
                                                             uri_routes, false)
        cached_router_version = user_routes.conf_version
        cached_service_version = service_version
    end

    if not uri_router then
        core.log.error("failed to fetch valid `uri` router: ")
        return true
    end

    return base_router.match_uri(uri_router, match_opts, api_ctx)
end


return _M
