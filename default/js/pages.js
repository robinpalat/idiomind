
function goPage()
{
   var dirPath = dirname(location.href);
   fullPath = dirPath + "/pg" + page + ".html";
   window.location=fullPath;
}
function dirname(path)
{
   return path.replace(/\\/g,'/').replace(/\/[^\/]*$/, '');
}

$('#next').click( function() {
    page = page + 1;
	if (page == 3)
	{
	page = 1
	}		
    goPage();
});

$('#previous').click( function() {
    page = page - 1;
	if (page == 0)
	{
	page = 2
	}
    goPage();
});
