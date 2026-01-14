var isAutomatic = false

function convertUrl() {
    const url = window.location.href
    const path = window.location.pathname
    const urlParams = new URLSearchParams(window.location.search)
    const base = isAutomatic ? "https://hako-3e13b.web.app/" : "hako://"
    
    if (path.startsWith("/topanime.php")) {
        let newUrl = `${base}top?type=anime`
        if (urlParams.has("type")) {
            newUrl += `&ranking=${urlParams.get("type")}`
        }
        window.location.replace(newUrl)
    } else if (path.startsWith("/topmanga.php")) {
        let newUrl = `${base}top?type=manga`
        if (urlParams.has("type")) {
            newUrl += `&ranking=${urlParams.get("type")}`
        }
        window.location.replace(newUrl)
    } else if (path.startsWith("/anime/season")) {
        let newUrl = `${base}seasons`
        const pathArray = path.slice(1).split("/")
        if (pathArray.length >= 4) {
            newUrl += `?year=${pathArray[2]}&season=${pathArray[3]}`
        }
        window.location.replace(newUrl)
    } else if (path.startsWith("/search/all") && urlParams.has("q")) {
        window.location.replace(`${base}explore?query=${urlParams.get("q")}`)
    } else if (path.startsWith("/anime.php")) {
        window.location.replace(`${base}explore?type=anime`)
    } else if (path.startsWith("/manga.php")) {
        window.location.replace(`${base}explore?type=manga`)
    } else if (path.startsWith("/character.php")) {
        window.location.replace(`${base}explore?type=characters`)
    } else if (path.startsWith("/people.php")) {
        window.location.replace(`${base}explore?type=people`)
    } else if (path.startsWith("/news")) {
        window.location.replace(`${base}news`)
    } else if (path.startsWith("/anime/genre")) {
        const pathArray = path.slice(1).split("/")
        if (pathArray.length >= 3) {
            window.location.replace(`${base}genre?type=anime&id=${pathArray[2]}`)
        }
    } else if (path.startsWith("/manga/genre")) {
        const pathArray = path.slice(1).split("/")
        if (pathArray.length >= 3) {
            window.location.replace(`${base}genre?type=manga&id=${pathArray[2]}`)
        }
    } else if (path.startsWith("/anime/producer")) {
        const pathArray = path.slice(1).split("/")
        if (pathArray.length >= 3) {
            const name = encodeURIComponent(document.title.split(" - ")[0])
            window.location.replace(`${base}producer?id=${pathArray[2]}&name=${name}`)
        } else {
            window.location.replace(`${base}explore?type=studios`)
        }
    } else if (path.startsWith("/manga/magazine")) {
        const pathArray = path.slice(1).split("/")
        if (pathArray.length >= 3) {
            const name = encodeURIComponent(document.title.split(" - ")[0])
            window.location.replace(`${base}magazine?id=${pathArray[2]}&name=${name}`)
        } else {
            window.location.replace(`${base}explore?type=magazines`)
        }
    } else if (path.startsWith("/animelist")) {
        const pathArray = path.slice(1).split("/")
        if (pathArray.length >= 2) {
            let newUrl = `${base}mylist?type=anime&user=${pathArray[1]}`
            if (urlParams.has("status")) {
                switch(urlParams.get("status")) {
                    case "1":
                        newUrl += "&status=watching"
                        break
                    case "2":
                        newUrl += "&status=completed"
                        break
                    case "3":
                        newUrl += "&status=onHold"
                        break
                    case "4":
                        newUrl += "&status=dropped"
                        break
                    case "6":
                        newUrl += "&status=planToWatch"
                        break
                    default:
                        status = "none"
                }
            }
            if (urlParams.has("order")) {
                switch(urlParams.get("order")) {
                    case "-4":
                        newUrl += "&sort=listScore"
                        break
                    case "-5":
                        newUrl += "&sort=listUpdatedAt"
                        break
                    case "1":
                        newUrl += "&sort=animeTitle"
                        break
                    case "-14":
                        newUrl += "&sort=animeStartDate"
                        break
                }
            }
            window.location.replace(newUrl)
        }
    } else if (path.startsWith("/mangalist")) {
        const pathArray = path.slice(1).split("/")
        if (pathArray.length >= 2) {
            let newUrl = `${base}mylist?type=manga&user=${pathArray[1]}`
            if (urlParams.has("status")) {
                switch(urlParams.get("status")) {
                    case "1":
                        newUrl += "&status=reading"
                        break
                    case "2":
                        newUrl += "&status=completed"
                        break
                    case "3":
                        newUrl += "&status=onHold"
                        break
                    case "4":
                        newUrl += "&status=dropped"
                        break
                    case "6":
                        newUrl += "&status=planToRead"
                        break
                    default:
                        status = "none"
                }
            }
            if (urlParams.has("order")) {
                switch(urlParams.get("order")) {
                    case "-4":
                        newUrl += "&sort=listScore"
                        break
                    case "-5":
                        newUrl += "&sort=listUpdatedAt"
                        break
                    case "1":
                        newUrl += "&sort=mangaTitle"
                        break
                    case "-12":
                        newUrl += "&sort=mangaStartDate"
                        break
                }
            }
            window.location.replace(newUrl)
        }
    } else if (path.startsWith("/anime")) {
        const pathArray = path.slice(1).split("/")
        if (pathArray.length >= 2) {
            window.location.replace(`${base}anime?id=${pathArray[1]}`)
        }
    } else if (path.startsWith("/manga")) {
        const pathArray = path.slice(1).split("/")
        if (pathArray.length >= 2) {
            window.location.replace(`${base}manga?id=${pathArray[1]}`)
        }
    } else if (path.startsWith("/character")) {
        const pathArray = path.slice(1).split("/")
        if (pathArray.length >= 2) {
            window.location.replace(`${base}character?id=${pathArray[1]}`)
        }
    } else if (path.startsWith("/people")) {
        const pathArray = path.slice(1).split("/")
        if (pathArray.length >= 2) {
            window.location.replace(`${base}person?id=${pathArray[1]}`)
        }
    }
}

browser.storage.local.get((item) => {
    var automaticObj = item.automaticObj;

    if (automaticObj == undefined) {
        isAutomatic = true;
    } else {
        isAutomatic = automaticObj.isAutomatic;
    }
    
    convertUrl()
})
