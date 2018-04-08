var categories =  Array.prototype.slice.call(document.querySelectorAll("a.category"));
categories.sort((x, y) => parseInt(x.dataset.cid) - parseInt(y.dataset.cid));
categories.filter((category) => category.className == "category toggle" && category.dataset.cid != undefined).forEach((category) => console.log(parseInt(category.dataset.cid) + " => \"" + category.innerText + "\","));