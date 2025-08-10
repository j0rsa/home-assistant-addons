#!/usr/bin/env python3
"""
Convert VLESS and Shadowsocks links to Xray configuration format.

Usage:
    python convert_links.py "vless://..." [--output config.json] [--proxy-port 8080]
    python convert_links.py "ss://..." [--output config.json] [--proxy-port 8080]
"""

import argparse
import base64
import json
import sys
import urllib.parse
from typing import Dict, Any, Optional


def parse_vless_link(vless_url: str) -> Dict[str, Any]:
    """Parse VLESS URL and return connection parameters."""
    if not vless_url.startswith('vless://'):
        raise ValueError("Invalid VLESS URL")
    
    # Remove vless:// prefix
    url_part = vless_url[8:]
    
    # Split user info and server info
    if '@' not in url_part:
        raise ValueError("Invalid VLESS URL format")
    
    user_part, server_part = url_part.split('@', 1)
    
    # Parse user ID
    user_id = user_part
    
    # Parse server part (may contain query parameters and fragment)
    if '#' in server_part:
        server_part, name = server_part.rsplit('#', 1)
        name = urllib.parse.unquote(name)
    else:
        name = "VLESS Server"
    
    if '?' in server_part:
        server_info, query_string = server_part.split('?', 1)
        params = urllib.parse.parse_qs(query_string)
    else:
        server_info = server_part
        params = {}
    
    # Parse server and port
    if ':' in server_info:
        server, port = server_info.rsplit(':', 1)
        port = int(port)
    else:
        server = server_info
        port = 443
    
    # Extract parameters
    config = {
        'server': server,
        'port': port,
        'user_id': user_id,
        'name': name,
        'encryption': params.get('encryption', ['none'])[0],
        'flow': params.get('flow', [''])[0],
        'security': params.get('security', ['tls'])[0],
        'sni': params.get('sni', [''])[0],
        'alpn': params.get('alpn', [''])[0],
        'fp': params.get('fp', [''])[0],  # fingerprint
        'type': params.get('type', ['tcp'])[0],  # network type
        'path': params.get('path', [''])[0],
        'host': params.get('host', [''])[0],
        'headerType': params.get('headerType', [''])[0],
        # REALITY specific parameters
        'pbk': params.get('pbk', [''])[0],  # public key
        'sid': params.get('sid', [''])[0],  # short ID
        'password': params.get('password', [''])[0],  # REALITY password
    }
    
    return config


def parse_shadowsocks_link(ss_url: str) -> Dict[str, Any]:
    """Parse Shadowsocks URL and return connection parameters."""
    if not ss_url.startswith('ss://'):
        raise ValueError("Invalid Shadowsocks URL")
    
    # Remove ss:// prefix
    url_part = ss_url[5:]
    
    # Handle fragment (name)
    if '#' in url_part:
        url_part, name = url_part.rsplit('#', 1)
        name = urllib.parse.unquote(name)
    else:
        name = "Shadowsocks Server"
    
    # Decode base64 if needed
    if '@' not in url_part:
        # Old format: ss://base64(method:password@server:port)
        try:
            decoded = base64.b64decode(url_part).decode('utf-8')
            if '@' in decoded:
                method_password, server_port = decoded.split('@', 1)
                if ':' in method_password:
                    method, password = method_password.split(':', 1)
                else:
                    raise ValueError("Invalid format")
            else:
                raise ValueError("Invalid format")
        except Exception:
            raise ValueError("Invalid Shadowsocks URL format")
    else:
        # New format: ss://base64(method:password)@server:port
        try:
            auth_part, server_port = url_part.split('@', 1)
            decoded_auth = base64.b64decode(auth_part).decode('utf-8')
            if ':' in decoded_auth:
                method, password = decoded_auth.split(':', 1)
            else:
                raise ValueError("Invalid auth format")
        except Exception:
            raise ValueError("Invalid Shadowsocks URL format")
    
    # Parse server and port
    if ':' in server_port:
        server, port = server_port.rsplit(':', 1)
        port = int(port)
    else:
        raise ValueError("Invalid server:port format")
    
    config = {
        'server': server,
        'port': port,
        'method': method,
        'password': password,
        'name': name
    }
    
    return config


def create_xray_config_vless(vless_config: Dict[str, Any], proxy_port: int = 8080) -> Dict[str, Any]:
    """Create Xray configuration for VLESS."""
    
    # Build stream settings
    stream_settings = {
        "network": vless_config.get('type', 'tcp')
    }
    
    # Security settings
    security = vless_config.get('security', 'tls')
    if security == 'tls':
        stream_settings['security'] = 'tls'
        tls_settings = {}
        if vless_config.get('sni'):
            tls_settings['serverName'] = vless_config['sni']
        if vless_config.get('alpn'):
            tls_settings['alpn'] = vless_config['alpn'].split(',')
        if vless_config.get('fp'):
            tls_settings['fingerprint'] = vless_config['fp']
        if tls_settings:
            stream_settings['tlsSettings'] = tls_settings
    elif security == 'reality':
        stream_settings['security'] = 'reality'
        reality_settings = {}
        if vless_config.get('sni'):
            reality_settings['serverName'] = vless_config['sni']
        if vless_config.get('fp'):
            reality_settings['fingerprint'] = vless_config['fp']
        # Required fields for REALITY
        if vless_config.get('pbk'):  # public key
            reality_settings['publicKey'] = vless_config['pbk']
        if vless_config.get('sid'):  # short ID
            reality_settings['shortId'] = vless_config['sid']
        # Set empty password if not provided (REALITY requirement)
        reality_settings['password'] = vless_config.get('password', '')
        # Always set realitySettings for reality security, even if minimal
        stream_settings['realitySettings'] = reality_settings
    
    # Network-specific settings
    network = vless_config.get('type', 'tcp')
    if network == 'ws':
        ws_settings = {}
        if vless_config.get('path'):
            ws_settings['path'] = vless_config['path']
        if vless_config.get('host'):
            ws_settings['headers'] = {'Host': vless_config['host']}
        if ws_settings:
            stream_settings['wsSettings'] = ws_settings
    elif network == 'grpc':
        grpc_settings = {}
        if vless_config.get('path'):
            grpc_settings['serviceName'] = vless_config['path']
        if grpc_settings:
            stream_settings['grpcSettings'] = grpc_settings
    elif network == 'h2':
        h2_settings = {}
        if vless_config.get('path'):
            h2_settings['path'] = vless_config['path']
        if vless_config.get('host'):
            h2_settings['host'] = [vless_config['host']]
        if h2_settings:
            stream_settings['httpSettings'] = h2_settings
    
    # Build user configuration
    user_config = {
        "id": vless_config['user_id'],
        "encryption": vless_config.get('encryption', 'none')
    }
    
    if vless_config.get('flow'):
        user_config['flow'] = vless_config['flow']
    
    config = {
        "log": {
            "loglevel": "warning"
        },
        "inbounds": [
            {
                "tag": "http-in",
                "port": proxy_port,
                "protocol": "http",
                "settings": {
                    "auth": "noauth",
                    "udp": False
                }
            }
        ],
        "outbounds": [
            {
                "tag": "vless-out",
                "protocol": "vless",
                "settings": {
                    "vnext": [
                        {
                            "address": vless_config['server'],
                            "port": vless_config['port'],
                            "users": [user_config]
                        }
                    ]
                },
                "streamSettings": stream_settings
            },
            {
                "tag": "direct",
                "protocol": "freedom"
            },
            {
                "tag": "blocked",
                "protocol": "blackhole"
            }
        ],
        "routing": {
            "rules": [
                {
                    "type": "field",
                    "ip": ["geoip:private"],
                    "outboundTag": "direct"
                }
            ]
        }
    }
    
    return config


def create_xray_config_shadowsocks(ss_config: Dict[str, Any], proxy_port: int = 8080) -> Dict[str, Any]:
    """Create Xray configuration for Shadowsocks."""
    
    config = {
        "log": {
            "loglevel": "warning"
        },
        "inbounds": [
            {
                "tag": "http-in",
                "port": proxy_port,
                "protocol": "http",
                "settings": {
                    "auth": "noauth",
                    "udp": False
                }
            }
        ],
        "outbounds": [
            {
                "tag": "ss-out",
                "protocol": "shadowsocks",
                "settings": {
                    "servers": [
                        {
                            "address": ss_config['server'],
                            "port": ss_config['port'],
                            "method": ss_config['method'],
                            "password": ss_config['password']
                        }
                    ]
                }
            },
            {
                "tag": "direct",
                "protocol": "freedom"
            },
            {
                "tag": "blocked",
                "protocol": "blackhole"
            }
        ],
        "routing": {
            "rules": [
                {
                    "type": "field",
                    "ip": ["geoip:private"],
                    "outboundTag": "direct"
                }
            ]
        }
    }
    
    return config


def main():
    parser = argparse.ArgumentParser(description='Convert VLESS/SS links to Xray configuration')
    parser.add_argument('url', help='VLESS or Shadowsocks URL')
    parser.add_argument('--output', '-o', help='Output file (default: stdout)')
    parser.add_argument('--proxy-port', '-p', type=int, default=8080, 
                        help='HTTP proxy port (default: 8080)')
    parser.add_argument('--base64', '-b', action='store_true',
                        help='Output base64 encoded configuration')
    
    args = parser.parse_args()
    
    try:
        if args.url.startswith('vless://'):
            print("Parsing VLESS URL...", file=sys.stderr)
            vless_config = parse_vless_link(args.url)
            xray_config = create_xray_config_vless(vless_config, args.proxy_port)
        elif args.url.startswith('ss://'):
            print("Parsing Shadowsocks URL...", file=sys.stderr)
            ss_config = parse_shadowsocks_link(args.url)
            xray_config = create_xray_config_shadowsocks(ss_config, args.proxy_port)
        else:
            print("Error: Unsupported URL format. Only VLESS and Shadowsocks URLs are supported.", file=sys.stderr)
            sys.exit(1)
        
        # Convert to JSON
        json_output = json.dumps(xray_config, indent=2, ensure_ascii=False)
        
        if args.base64:
            # Encode as base64
            json_bytes = json_output.encode('utf-8')
            base64_output = base64.b64encode(json_bytes).decode('ascii')
            output = base64_output
        else:
            output = json_output
        
        # Output result
        if args.output:
            with open(args.output, 'w', encoding='utf-8') as f:
                f.write(output)
            print(f"Configuration saved to {args.output}", file=sys.stderr)
        else:
            print(output)
            
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()