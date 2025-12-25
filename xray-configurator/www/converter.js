// JavaScript implementation of the VLESS and Shadowsocks link converter

class XrayConverter {
    parseVlessLink(vlessUrl) {
        if (!vlessUrl.startsWith('vless://')) {
            throw new Error('Invalid VLESS URL');
        }

        // Remove vless:// prefix
        let urlPart = vlessUrl.substring(8);

        // Split user info and server info
        const atIndex = urlPart.indexOf('@');
        if (atIndex === -1) {
            throw new Error('Invalid VLESS URL format');
        }

        const userPart = urlPart.substring(0, atIndex);
        let serverPart = urlPart.substring(atIndex + 1);

        // Parse user ID
        const userId = userPart;

        // Parse server part (may contain query parameters and fragment)
        let name = 'VLESS Server';
        const hashIndex = serverPart.lastIndexOf('#');
        if (hashIndex !== -1) {
            name = decodeURIComponent(serverPart.substring(hashIndex + 1));
            serverPart = serverPart.substring(0, hashIndex);
        }

        let params = {};
        const questionIndex = serverPart.indexOf('?');
        let serverInfo;
        if (questionIndex !== -1) {
            serverInfo = serverPart.substring(0, questionIndex);
            const queryString = serverPart.substring(questionIndex + 1);
            params = this.parseQueryString(queryString);
        } else {
            serverInfo = serverPart;
        }

        // Parse server and port
        let server, port;
        const colonIndex = serverInfo.lastIndexOf(':');
        if (colonIndex !== -1) {
            server = serverInfo.substring(0, colonIndex);
            port = parseInt(serverInfo.substring(colonIndex + 1));
        } else {
            server = serverInfo;
            port = 443;
        }

        return {
            server: server,
            port: port,
            user_id: userId,
            name: name,
            encryption: params.encryption || 'none',
            flow: params.flow || '',
            security: params.security || 'tls',
            sni: params.sni || '',
            alpn: params.alpn || '',
            fp: params.fp || '',
            type: params.type || 'tcp',
            path: params.path || '',
            host: params.host || '',
            headerType: params.headerType || '',
            pbk: params.pbk || '',
            sid: params.sid || '',
            password: params.password || ''
        };
    }

    parseShadowsocksLink(ssUrl) {
        if (!ssUrl.startsWith('ss://')) {
            throw new Error('Invalid Shadowsocks URL');
        }

        // Remove ss:// prefix
        let urlPart = ssUrl.substring(5);

        // Handle fragment (name)
        let name = 'Shadowsocks Server';
        const hashIndex = urlPart.lastIndexOf('#');
        if (hashIndex !== -1) {
            name = decodeURIComponent(urlPart.substring(hashIndex + 1));
            urlPart = urlPart.substring(0, hashIndex);
        }

        let method, password, server, port;

        if (urlPart.indexOf('@') === -1) {
            // Old format: ss://base64(method:password@server:port)
            try {
                const decoded = atob(urlPart);
                const atIndex = decoded.indexOf('@');
                if (atIndex === -1) throw new Error('Invalid format');
                
                const methodPassword = decoded.substring(0, atIndex);
                const serverPort = decoded.substring(atIndex + 1);
                
                const colonIndex = methodPassword.indexOf(':');
                if (colonIndex === -1) throw new Error('Invalid format');
                
                method = methodPassword.substring(0, colonIndex);
                password = methodPassword.substring(colonIndex + 1);
                
                const portColonIndex = serverPort.lastIndexOf(':');
                if (portColonIndex === -1) throw new Error('Invalid server:port format');
                
                server = serverPort.substring(0, portColonIndex);
                port = parseInt(serverPort.substring(portColonIndex + 1));
            } catch (e) {
                throw new Error('Invalid Shadowsocks URL format');
            }
        } else {
            // New format: ss://base64(method:password)@server:port
            try {
                const atIndex = urlPart.indexOf('@');
                const authPart = urlPart.substring(0, atIndex);
                const serverPort = urlPart.substring(atIndex + 1);
                
                const decodedAuth = atob(authPart);
                const colonIndex = decodedAuth.indexOf(':');
                if (colonIndex === -1) throw new Error('Invalid auth format');
                
                method = decodedAuth.substring(0, colonIndex);
                password = decodedAuth.substring(colonIndex + 1);
                
                const portColonIndex = serverPort.lastIndexOf(':');
                if (portColonIndex === -1) throw new Error('Invalid server:port format');
                
                server = serverPort.substring(0, portColonIndex);
                port = parseInt(serverPort.substring(portColonIndex + 1));
            } catch (e) {
                throw new Error('Invalid Shadowsocks URL format');
            }
        }

        return {
            server: server,
            port: port,
            method: method,
            password: password,
            name: name
        };
    }

    parseQueryString(queryString) {
        const params = {};
        const pairs = queryString.split('&');
        for (const pair of pairs) {
            const [key, value] = pair.split('=');
            if (key && value) {
                params[decodeURIComponent(key)] = decodeURIComponent(value);
            }
        }
        return params;
    }

    createXrayConfigVless(vlessConfig, proxyPort = 8080, socksPort = 1080, enableHttp = true, enableSocks = true, enableSocksAuth = false, authUsers = []) {
        // Build stream settings
        const streamSettings = {
            network: vlessConfig.type || 'tcp'
        };

        // Security settings
        const security = vlessConfig.security || 'tls';
        if (security === 'tls') {
            streamSettings.security = 'tls';
            const tlsSettings = {};
            if (vlessConfig.sni) tlsSettings.serverName = vlessConfig.sni;
            if (vlessConfig.alpn) tlsSettings.alpn = vlessConfig.alpn.split(',');
            if (vlessConfig.fp) tlsSettings.fingerprint = vlessConfig.fp;
            if (Object.keys(tlsSettings).length > 0) {
                streamSettings.tlsSettings = tlsSettings;
            }
        } else if (security === 'reality') {
            streamSettings.security = 'reality';
            const realitySettings = {};
            if (vlessConfig.sni) realitySettings.serverName = vlessConfig.sni;
            if (vlessConfig.fp) realitySettings.fingerprint = vlessConfig.fp;
            if (vlessConfig.pbk) realitySettings.publicKey = vlessConfig.pbk;
            if (vlessConfig.sid) realitySettings.shortId = vlessConfig.sid;
            realitySettings.password = vlessConfig.password || '';
            streamSettings.realitySettings = realitySettings;
        }

        // Network-specific settings
        const network = vlessConfig.type || 'tcp';
        if (network === 'ws') {
            const wsSettings = {};
            if (vlessConfig.path) wsSettings.path = vlessConfig.path;
            if (vlessConfig.host) wsSettings.headers = { Host: vlessConfig.host };
            if (Object.keys(wsSettings).length > 0) {
                streamSettings.wsSettings = wsSettings;
            }
        } else if (network === 'grpc') {
            const grpcSettings = {};
            if (vlessConfig.path) grpcSettings.serviceName = vlessConfig.path;
            if (Object.keys(grpcSettings).length > 0) {
                streamSettings.grpcSettings = grpcSettings;
            }
        } else if (network === 'h2') {
            const h2Settings = {};
            if (vlessConfig.path) h2Settings.path = vlessConfig.path;
            if (vlessConfig.host) h2Settings.host = [vlessConfig.host];
            if (Object.keys(h2Settings).length > 0) {
                streamSettings.httpSettings = h2Settings;
            }
        }

        // Build user configuration
        const userConfig = {
            id: vlessConfig.user_id,
            encryption: vlessConfig.encryption || 'none'
        };

        if (vlessConfig.flow) {
            userConfig.flow = vlessConfig.flow;
        }

        // Build inbounds array based on enabled options
        const inbounds = [];
        
        if (enableHttp) {
            inbounds.push({
                tag: 'http-in',
                port: proxyPort,
                protocol: 'http',
                settings: {
                    auth: 'noauth',
                    udp: false
                }
            });
        }
        
        if (enableSocks) {
            const socksInbound = {
                tag: 'socks-in',
                listen: '0.0.0.0',
                port: socksPort,
                protocol: 'socks',
                settings: {
                    udp: true
                }
            };

            if (enableSocksAuth && authUsers.length > 0) {
                socksInbound.settings.auth = 'password';
                socksInbound.settings.accounts = authUsers.map(user => ({
                    user: user.username,
                    pass: user.password
                }));
            } else {
                socksInbound.settings.auth = 'noauth';
            }

            inbounds.push(socksInbound);
        }

        return {
            log: {
                loglevel: 'warning'
            },
            inbounds: inbounds,
            outbounds: [
                {
                    tag: 'vless-out',
                    protocol: 'vless',
                    settings: {
                        vnext: [
                            {
                                address: vlessConfig.server,
                                port: vlessConfig.port,
                                users: [userConfig]
                            }
                        ]
                    },
                    streamSettings: streamSettings
                },
                {
                    tag: 'direct',
                    protocol: 'freedom'
                },
                {
                    tag: 'blocked',
                    protocol: 'blackhole'
                }
            ],
            routing: {
                rules: [
                    {
                        "type": "field",
                        "inboundTag": ["socks-in", "http-in"],
                        "outboundTag": "vless-out"
                    },
                    {
                        type: 'field',
                        ip: ['geoip:private'],
                        outboundTag: 'direct'
                    }
                ]
            }
        };
    }

    createXrayConfigShadowsocks(ssConfig, proxyPort = 8080, socksPort = 1080, enableHttp = true, enableSocks = true, enableSocksAuth = false, authUsers = []) {
        // Build inbounds array based on enabled options
        const inbounds = [];
        
        if (enableHttp) {
            inbounds.push({
                tag: 'http-in',
                port: proxyPort,
                protocol: 'http',
                settings: {
                    auth: 'noauth',
                    udp: false
                }
            });
        }
        
        if (enableSocks) {
            const socksInbound = {
                tag: 'socks-in',
                listen: '0.0.0.0',
                port: socksPort,
                protocol: 'socks',
                settings: {
                    udp: true
                }
            };

            if (enableSocksAuth && authUsers.length > 0) {
                socksInbound.settings.auth = 'password';
                socksInbound.settings.accounts = authUsers.map(user => ({
                    user: user.username,
                    pass: user.password
                }));
            } else {
                socksInbound.settings.auth = 'noauth';
            }

            inbounds.push(socksInbound);
        }

        return {
            log: {
                loglevel: 'warning'
            },
            inbounds: inbounds,
            outbounds: [
                {
                    tag: 'ss-out',
                    protocol: 'shadowsocks',
                    settings: {
                        servers: [
                            {
                                address: ssConfig.server,
                                port: ssConfig.port,
                                method: ssConfig.method,
                                password: ssConfig.password
                            }
                        ]
                    }
                },
                {
                    tag: 'direct',
                    protocol: 'freedom'
                },
                {
                    tag: 'blocked',
                    protocol: 'blackhole'
                }
            ],
            routing: {
                rules: [
                    {
                        type: 'field',
                        ip: ['geoip:private'],
                        outboundTag: 'direct'
                    }
                ]
            }
        };
    }

    convertLink(url, proxyPort = 8080, socksPort = 1080, enableHttp = true, enableSocks = true, enableSocksAuth = false, authUsers = []) {
        try {
            let xrayConfig;
            
            if (url.startsWith('vless://')) {
                const vlessConfig = this.parseVlessLink(url);
                xrayConfig = this.createXrayConfigVless(vlessConfig, proxyPort, socksPort, enableHttp, enableSocks, enableSocksAuth, authUsers);
            } else if (url.startsWith('ss://')) {
                const ssConfig = this.parseShadowsocksLink(url);
                xrayConfig = this.createXrayConfigShadowsocks(ssConfig, proxyPort, socksPort, enableHttp, enableSocks, enableSocksAuth, authUsers);
            } else {
                throw new Error('Unsupported URL format. Only VLESS and Shadowsocks URLs are supported.');
            }

            const jsonOutput = JSON.stringify(xrayConfig, null, 2);
            const base64Output = btoa(jsonOutput);

            return {
                json: jsonOutput,
                base64: base64Output,
                success: true
            };
        } catch (error) {
            return {
                error: error.message,
                success: false
            };
        }
    }
}