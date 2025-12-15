// Gestor de instalaciones para comunidades energéticas
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

  // Función para escapar HTML
  function escapeHtml(text) {
    if (!text) return '';
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }

  // Función para cargar instalaciones existentes
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

  // Función para añadir una instalación al DOM
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
          <label class="text-sm font-medium">Ubicación</label>
          <input type="text" 
                 class="installation-location form-control" 
                 value="${locationValue}" 
                 placeholder="Ej: Edificio A, Tejado Principal"
                 required>
        </div>
        <div>
          <label class="text-sm font-medium">Potencia Pico (kWp)</label>
          <input type="number" 
                 class="installation-power form-control" 
                 value="${powerValue}" 
                 placeholder="Ej: 50"
                 step="0.01"
                 min="0"
                 required>
        </div>
        <div class="flex items-end">
          <button type="button" 
                  class="remove-installation-btn button button__sm button__text-secondary w-full"
                  data-installation-id="${installationId}">
            Eliminar instalación
          </button>
        </div>
      </div>
    `;

    installationsList.appendChild(installationDiv);

    // Event listeners para actualizar los datos
    const locationInput = installationDiv.querySelector('.installation-location');
    const powerInput = installationDiv.querySelector('.installation-power');
    const removeBtn = installationDiv.querySelector('.remove-installation-btn');

    locationInput.addEventListener('input', updateInstallationsData);
    powerInput.addEventListener('input', updateInstallationsData);
    removeBtn.addEventListener('click', function() {
      removeInstallation(installationId);
    });
  }

  // Función para añadir una nueva instalación
  function addNewInstallation() {
    const installation = {
      id: installationCounter++,
      location: '',
      power: ''
    };
    addInstallationToDOM(installation);
    updateInstallationsData();
  }

  // Función para eliminar una instalación
  function removeInstallation(installationId) {
    const installationDiv = document.querySelector(`[data-installation-id="${installationId}"]`);
    if (installationDiv) {
      installationDiv.remove();
      updateInstallationsData();
    }
  }

  // Función para actualizar los datos en el campo oculto
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

  // Toggle del contenedor de instalaciones
  hasInstallationsCheckbox.addEventListener('change', function() {
    if (this.checked) {
      installationsContainer.style.display = 'block';
      // Si no hay instalaciones, añadir una por defecto
      if (installations.length === 0) {
        addNewInstallation();
      }
    } else {
      installationsContainer.style.display = 'none';
      // Limpiar las instalaciones
      installationsList.innerHTML = '';
      installations = [];
      installationsDataInput.value = '';
    }
  });

  // Event listener para añadir instalaciones
  if (addInstallationBtn) {
    addInstallationBtn.addEventListener('click', addNewInstallation);
  }

  // Cargar instalaciones existentes si las hay
  loadExistingInstallations();
});

