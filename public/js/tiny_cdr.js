$(document).ready(function() {
  $('#user_calls').dataTable({
    "sDom": 'T<"clear">lfrtip',
    "oTableTools": {
      "sSwfPath": "/swf/copy_csv_xls_pdf.swf",
      "aButtons": [
                "copy",
                {
                    "sExtends": "pdf",
                    "sButtonText": "PDF - Reporting columns",
                    "mColumns": [ 0, 1, 2, 3, 4 ]
                },
                {
                    "sExtends": "pdf",
                    "sButtonText": "PDF - All",
                    "mColumns": "visible"
                },
                {
                    "sExtends": "print",
                    "sButtonText": "Print",
                    "mColumns": [ 0, 1, 2, 3, 4 ]
                },
                {
                    "sExtends": "csv",
                    "sButtonText": "CSV",
                    "mColumns": [ 0, 1, 2, 3, 4 ]
                }
            ]
    }
  });
});
