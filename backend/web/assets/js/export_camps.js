function loadCamps() {
    let campLocation = document.getElementById("campLocation").options[document.getElementById("campLocation").selectedIndex].value;
    let campDate = document.getElementById("campDate").value;
    let campFacility = document.getElementById("campFacility").value;
    let campNamePartial = document.getElementById("campName").value;

    let url = `/api/admin/camp/${campLocation}/${campDate}/${campFacility}/`;

    let output = document.getElementById("campResults");
    let campName = ""
    let facility = ""
    let campDescription = ""
    let supervisorName = ""
    let directorName = ""
    let camperCount = ""
    let room = ""
    let location = ""

    let templateOutput = `
    <div class="col-sm-12">
        <div class="alert alert-secondary" role="alert">
            <h4>${campName} @ ${facility} in ${room}</h4>
            <p>
                ${campDescription}
            </p>
            <hr />
            <div class="row">
                <div class="col-sm-10">
                    <p>
                        Camp Supervisor: ${supervisorName}<br>Camp Director: ${directorName}<br>Campers: ${camperCount}<br>Location: ${location}
                    </p>
                </div>
                <div class="col-sm-2 align-self-end">
                    <button type="button" class="btn btn-primary w-100 text-white">
                        Export
                    </button>
                </div>
            </div>
        </div>
    </div>
    `
}

function setup() {
    //Location setup

    //Facility setup
}