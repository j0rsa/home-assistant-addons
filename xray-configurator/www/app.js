// Main application logic
document.addEventListener('DOMContentLoaded', function() {
    const urlInput = document.getElementById('urlInput');
    const proxyPortInput = document.getElementById('proxyPort');
    const socksPortInput = document.getElementById('socksPort');
    const enableHttpCheckbox = document.getElementById('enableHttp');
    const enableSocksCheckbox = document.getElementById('enableSocks');
    const jsonOutput = document.getElementById('jsonOutput');
    const base64Output = document.getElementById('base64Output');
    const base64Header = document.getElementById('base64Header');
    const copyJsonBtn = document.getElementById('copyJsonBtn');
    const copyBase64Btn = document.getElementById('copyBase64Btn');
    const errorMessage = document.getElementById('errorMessage');
    const toast = document.getElementById('toast');
    const conversionStatus = document.getElementById('conversionStatus');

    const converter = new XrayConverter();
    let conversionTimeout;
    let jsonEditTimeout;
    let isJsonEdited = false;
    let originalJsonFromConverter = '';

    // Real-time conversion function
    function performConversion() {
        const url = urlInput.value.trim();
        const proxyPort = parseInt(proxyPortInput.value) || 8080;
        const socksPort = parseInt(socksPortInput.value) || 1080;
        const enableHttp = enableHttpCheckbox.checked;
        const enableSocks = enableSocksCheckbox.checked;

        // Clear previous timeout
        if (conversionTimeout) {
            clearTimeout(conversionTimeout);
        }

        if (!url) {
            clearOutputs();
            disableCopyButtons();
            hideError();
            updateStatus('Enter a URL to see the configuration', 'idle');
            resetJsonEditState();
            return;
        }

        // Check if at least one inbound is enabled
        if (!enableHttp && !enableSocks) {
            clearOutputs();
            disableCopyButtons();
            showError('Please enable at least one proxy type (HTTP or SOCKS)');
            updateStatus('No proxy types enabled', 'error');
            resetJsonEditState();
            return;
        }

        // Show converting status
        updateStatus('Converting...', 'converting');

        // Debounce conversion to avoid excessive calls
        conversionTimeout = setTimeout(() => {
            const result = converter.convertLink(url, proxyPort, socksPort, enableHttp, enableSocks);

            if (result.success) {
                // Store the original JSON from converter
                originalJsonFromConverter = result.json;
                
                // Only update JSON if it hasn't been manually edited
                if (!isJsonEdited) {
                    jsonOutput.value = result.json;
                }
                
                base64Output.value = result.base64;
                updateBase64Header(false);
                enableCopyButtons();
                hideError();
                updateStatus('Configuration ready!', 'success');
            } else {
                clearOutputs();
                disableCopyButtons();
                showError(result.error);
                updateStatus('Invalid URL format', 'error');
                resetJsonEditState();
            }
        }, 500); // 500ms debounce
    }

    // Add event listeners for real-time conversion
    urlInput.addEventListener('input', performConversion);
    proxyPortInput.addEventListener('input', performConversion);
    socksPortInput.addEventListener('input', performConversion);
    enableHttpCheckbox.addEventListener('change', handleCheckboxChange);
    enableSocksCheckbox.addEventListener('change', handleCheckboxChange);

    // Handle checkbox changes
    function handleCheckboxChange() {
        updateUIState();
        performConversion();
    }

    // Update UI state based on checkbox status
    function updateUIState() {
        const httpOptionGroup = enableHttpCheckbox.closest('.option-group');
        const socksOptionGroup = enableSocksCheckbox.closest('.option-group');
        
        // Toggle disabled state styling
        if (enableHttpCheckbox.checked) {
            httpOptionGroup.classList.remove('disabled');
            proxyPortInput.disabled = false;
        } else {
            httpOptionGroup.classList.add('disabled');
            proxyPortInput.disabled = true;
        }
        
        if (enableSocksCheckbox.checked) {
            socksOptionGroup.classList.remove('disabled');
            socksPortInput.disabled = false;
        } else {
            socksOptionGroup.classList.add('disabled');
            socksPortInput.disabled = true;
        }
    }

    // Initialize UI state
    updateUIState();

    // Handle JSON editing
    jsonOutput.addEventListener('input', handleJsonEdit);

    function handleJsonEdit() {
        // Clear previous timeout
        if (jsonEditTimeout) {
            clearTimeout(jsonEditTimeout);
        }

        // Debounce JSON processing
        jsonEditTimeout = setTimeout(() => {
            const currentJson = jsonOutput.value.trim();
            
            // Check if JSON has been modified from original
            isJsonEdited = currentJson !== originalJsonFromConverter;
            
            if (currentJson && isJsonEdited) {
                try {
                    // Validate JSON
                    JSON.parse(currentJson);
                    
                    // If valid, encode to base64
                    const base64Encoded = btoa(currentJson);
                    base64Output.value = base64Encoded;
                    updateBase64Header(true);
                    hideError();
                    
                } catch (e) {
                    // Invalid JSON - show error but don't update base64
                    showError('Invalid JSON format. Please check your syntax.');
                    updateBase64Header(true, true); // true for customized, true for error
                }
            } else if (!currentJson) {
                // Empty JSON
                base64Output.value = '';
                updateBase64Header(false);
                isJsonEdited = false;
            } else if (currentJson === originalJsonFromConverter) {
                // JSON was restored to original
                isJsonEdited = false;
                if (originalJsonFromConverter) {
                    const base64Encoded = btoa(originalJsonFromConverter);
                    base64Output.value = base64Encoded;
                    updateBase64Header(false);
                    hideError();
                }
            }
        }, 500); // 500ms debounce
    }

    function updateBase64Header(isCustomized, hasError = false) {
        if (hasError) {
            base64Header.textContent = 'Base64 Encoded Configuration (Invalid JSON)';
            base64Header.style.color = '#dc3545';
        } else if (isCustomized) {
            base64Header.textContent = 'Base64 Encoded Configuration (Customized)';
            base64Header.style.color = '#fd7e14'; // Orange color for customized
        } else {
            base64Header.textContent = 'Base64 Encoded Configuration';
            base64Header.style.color = '#333'; // Default color
        }
    }

    // Copy to clipboard functionality
    copyJsonBtn.addEventListener('click', function() {
        copyToClipboard(jsonOutput.value, 'JSON configuration copied to clipboard!');
    });

    copyBase64Btn.addEventListener('click', function() {
        copyToClipboard(base64Output.value, 'Base64 configuration copied to clipboard!');
    });

    // Enter key handler for URL input (now just focuses next input)
    urlInput.addEventListener('keydown', function(e) {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            proxyPortInput.focus();
        }
    });

    // Auto-resize textareas
    urlInput.addEventListener('input', autoResize);
    jsonOutput.addEventListener('input', autoResize);
    base64Output.addEventListener('input', autoResize);

    function autoResize(e) {
        const textarea = e.target;
        textarea.style.height = 'auto';
        textarea.style.height = textarea.scrollHeight + 'px';
    }

    function copyToClipboard(text, successMessage) {
        if (!text) {
            showError('Nothing to copy');
            return;
        }

        navigator.clipboard.writeText(text).then(() => {
            showToast(successMessage);
        }).catch(err => {
            // Fallback for older browsers
            const textArea = document.createElement('textarea');
            textArea.value = text;
            document.body.appendChild(textArea);
            textArea.select();
            
            try {
                document.execCommand('copy');
                showToast(successMessage);
            } catch (err) {
                showError('Failed to copy to clipboard');
            }
            
            document.body.removeChild(textArea);
        });
    }

    function showError(message) {
        errorMessage.textContent = message;
        errorMessage.classList.add('show');
        
        // Auto-hide after 5 seconds
        setTimeout(() => {
            hideError();
        }, 5000);
    }

    function hideError() {
        errorMessage.classList.remove('show');
    }

    function showSuccess(message) {
        showToast(message);
    }

    function showToast(message) {
        toast.textContent = message;
        toast.classList.add('show');
        
        setTimeout(() => {
            toast.classList.remove('show');
        }, 3000);
    }

    function clearOutputs() {
        jsonOutput.value = '';
        base64Output.value = '';
        updateBase64Header(false);
    }

    function resetJsonEditState() {
        isJsonEdited = false;
        originalJsonFromConverter = '';
        updateBase64Header(false);
    }

    function enableCopyButtons() {
        copyJsonBtn.disabled = false;
        copyBase64Btn.disabled = false;
    }

    function disableCopyButtons() {
        copyJsonBtn.disabled = true;
        copyBase64Btn.disabled = true;
    }

    function updateStatus(message, type = 'idle') {
        conversionStatus.textContent = message;
        conversionStatus.className = `status-text status-${type}`;
    }

    // Initialize with disabled copy buttons
    disableCopyButtons();

    // Example URLs for testing (can be removed in production)
    const examples = {
        vless: 'vless://12345678-1234-1234-1234-123456789abc@example.com:443?encryption=none&security=tls&sni=example.com&type=tcp#My%20VLESS%20Server',
        shadowsocks: 'ss://YWVzLTI1Ni1nY206cGFzc3dvcmQ@example.com:8388#My%20SS%20Server'
    };

    // Add example buttons (optional)
    if (window.location.hostname === 'localhost') {
        const exampleDiv = document.createElement('div');
        exampleDiv.className = 'examples';
        exampleDiv.innerHTML = `
            <p style="margin-bottom: 10px; font-size: 0.9rem; color: #666;">Quick examples:</p>
            <button class="example-btn" data-example="vless">VLESS Example</button>
            <button class="example-btn" data-example="shadowsocks">Shadowsocks Example</button>
        `;
        
        urlInput.parentNode.insertBefore(exampleDiv, urlInput);
        
        document.querySelectorAll('.example-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                const example = this.dataset.example;
                urlInput.value = examples[example];
                autoResize({ target: urlInput });
                resetJsonEditState(); // Reset edit state for new example
                performConversion(); // Trigger conversion for example
            });
        });
        
        // Add CSS for example buttons
        const style = document.createElement('style');
        style.textContent = `
            .examples { margin-bottom: 15px; }
            .example-btn {
                background: #f8f9fa;
                border: 1px solid #dee2e6;
                padding: 4px 8px;
                margin-right: 8px;
                border-radius: 4px;
                font-size: 0.8rem;
                cursor: pointer;
            }
            .example-btn:hover {
                background: #e9ecef;
            }
        `;
        document.head.appendChild(style);
    }
});