// Installation manager for energy communities
document.addEventListener('DOMContentLoaded', function() {
  const hasInstallationsCheckbox = document.getElementById('group_has_installations');
  const installationsContainer = document.getElementById('installations-container');
  const installationsList = document.getElementById('installations-list');
  const addInstallationBtn = document.getElementById('add-installation-btn');
  const installationsDataInput = document.getElementById('installations-data');

  if (!hasInstallationsCheckbox || !installationsContainer) {
    return;
  }

  let installations = [];
  let installationCounter = 0;

  // Get translations from data attributes
  const i18n = {
    locationLabel: installationsContainer.dataset.locationLabel || 'Ubicación',
    locationPlaceholder: installationsContainer.dataset.locationPlaceholder || 'Ej: Edificio A, Tejado Principal',
    powerLabel: installationsContainer.dataset.powerLabel || 'Potencia Pico (kWp)',
    powerPlaceholder: installationsContainer.dataset.powerPlaceholder || 'Ej: 10',
    removeBtnText: installationsContainer.dataset.removeBtnText || 'Eliminar instalación'
  };

  // Function to escape HTML
  function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }

  // Function to load existing installations
  function loadExistingInstallations() {
    const dataValue = installationsDataInput.value;

    if (dataValue && dataValue.trim() !== '') {
      try {
        installations = JSON.parse(dataValue);

        if (Array.isArray(installations) && installations.length > 0) {
          installations.forEach((installation, index) => {
            installation.id = index;
            addInstallationToDOM(installation);
            installationCounter++;
          });
          hasInstallationsCheckbox.checked = true;
          installationsContainer.style.display = 'block';
        }
      } catch (e) {
        console.error('Error parsing installations data:', e);
        console.error('Data value was:', dataValue);
      }
    }
  }

  // Function to add an installation to the DOM
  function addInstallationToDOM(installation) {
    const installationId = installation.id !== undefined ? installation.id : installationCounter++;
    const installationDiv = document.createElement('div');
    installationDiv.className = 'installation-item border border-gray-300 rounded p-4 mb-3';
    installationDiv.dataset.installationId = installationId;

    const locationValue = escapeHtml(installation.location || '');
    const powerValue = installation.power || '';

    installationDiv.innerHTML = `
      <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mb-2">
        <div>
          <label class="text-sm font-medium">${escapeHtml(i18n.locationLabel)}</label>
          <input type="text" 
                 class="installation-location form-control" 
                 value="${locationValue}" 
                 placeholder="${escapeHtml(i18n.locationPlaceholder)}"
                 required>
        </div>
        <div>
          <label class="text-sm font-medium">${escapeHtml(i18n.powerLabel)}</label>
          <input type="number" 
                 class="installation-power form-control" 
                 value="${powerValue}" 
                 placeholder="${escapeHtml(i18n.powerPlaceholder)}"
                 step="0.01"
                 min="0"
                 required>
        </div>
        <div class="flex items-end">
          <button type="button" 
                  class="remove-installation-btn button button__sm button__text-secondary w-full"
                  data-installation-id="${installationId}">
            ${escapeHtml(i18n.removeBtnText)}
          </button>
        </div>
      </div>
    `;

    installationsList.appendChild(installationDiv);

    // Event listeners to update data
    const locationInput = installationDiv.querySelector('.installation-location');
    const powerInput = installationDiv.querySelector('.installation-power');
    const removeBtn = installationDiv.querySelector('.remove-installation-btn');

    locationInput.addEventListener('input', updateInstallationsData);
    powerInput.addEventListener('input', updateInstallationsData);
    removeBtn.addEventListener('click', function() {
      removeInstallation(installationId);
    });
  }

  // Function to add a new installation
  function addNewInstallation() {
    const installation = {
      id: installationCounter++,
      location: '',
      power: ''
    };
    addInstallationToDOM(installation);
    updateInstallationsData();
  }

  // Function to remove an installation
  function removeInstallation(installationId) {
    const installationDiv = document.querySelector(`[data-installation-id="${installationId}"]`);
    if (installationDiv) {
      installationDiv.remove();
      updateInstallationsData();

      // If no installations remain, uncheck the checkbox and hide the container
      const remainingInstallations = document.querySelectorAll('.installation-item');
      if (remainingInstallations.length === 0) {
        hasInstallationsCheckbox.checked = false;
        installationsContainer.style.display = 'none';
        installations = [];
        installationsDataInput.value = '';
      }
    }
  }

  // Function to update data in the hidden field
  function updateInstallationsData() {
    const installationItems = document.querySelectorAll('.installation-item');
    installations = [];

    installationItems.forEach(item => {
      const location = item.querySelector('.installation-location').value;
      const power = item.querySelector('.installation-power').value;

      if (location || power) {
        installations.push({
          location: location,
          power: power
        });
      }
    });

    installationsDataInput.value = JSON.stringify(installations);
  }

  // Toggle installations container
  hasInstallationsCheckbox.addEventListener('change', function() {
    if (this.checked) {
      installationsContainer.style.display = 'block';
      // If there are no installations, add one by default
      if (installations.length === 0) {
        addNewInstallation();
      }
    } else {
      installationsContainer.style.display = 'none';
      // Clear installations
      installationsList.innerHTML = '';
      installations = [];
      installationsDataInput.value = '';
    }
  });

  // Event listener to add installations
  if (addInstallationBtn) {
    addInstallationBtn.addEventListener('click', addNewInstallation);
  }

  // Load existing installations if any
  loadExistingInstallations();
});

