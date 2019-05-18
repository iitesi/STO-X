(function($) { 
    $.fn.travelersAutocomplete = function (options) {
        const defaults = {
            query: {},
            userId: -1,
            accountId: -1,
            queryLimit: 200,
            elementName: 'UserID'
        };

        let settings = $.extend({},defaults, options);

        const suffixIdx = settings.query.COLUMNS.indexOf('NAME_SUFFIX');
        const firstIdx = settings.query.COLUMNS.indexOf('FIRST_NAME');
        const middleIdx = settings.query.COLUMNS.indexOf('MIDDLE_NAME');
        const lastIdx = settings.query.COLUMNS.indexOf('LAST_NAME');

        const displayName = function(row){
            let name = '';
            if (lastIdx > -1) {
                name += row[lastIdx];
            }
            if (suffixIdx > -1 && row[suffixIdx].length) {
                name += ' ' + row[suffixIdx];
            }
            if (name.length) {
                name += ', ';
            }
            if (firstIdx > -1) {
                name += row[firstIdx];
            }
            if (middleIdx > -1 && row[middleIdx].length) {
                name += ' ' + row[middleIdx];
            }
            return name;
        };

        const setValueFromId = function (mappedUserList, newValue){
            for (var i = 0; i < mappedUserList.length; i++){
                let user = mappedUserList[i];
                if(user.value == newValue){
                    $("#User_ID_Label").val(user.label);
                    break;
                }
            }
        }

        return this.each(function(){
            const $this = $(this);
            let mappedUserList = !settings.query.DATA ? [] : settings.query.DATA.map(function(i){return ({value:i[0],label:displayName(i)});});

            if (mappedUserList.length > settings.queryLimit){
                mappedUserList.push({label:'Guest',value:0});
                mappedUserList.push({label:'Myself',value:settings.userId});
                $this.prepend($('<input/>',{
                    id: 'User_ID_Label',
                    name: 'User_ID_Label',
                    type: 'text',
                    class: 'form-control',
                    placeholder: 'Myself   (type \'Guest\' or search by travler name)'
                }));
                $this.prepend($('<input/>',{
                    id: settings.elementName,
                    name: settings.elementName,
                    type: 'hidden',
                    value: settings.userId,
                    'data-initialvalue' : settings.userId
                }));
                $("#User_ID_Label").autocomplete({
                    source: mappedUserList,
                    focus: function (event, ui) {
                        event.preventDefault();
                        $(this).val(ui.item.label);
                    },
                    select: function (event, ui) {
                        event.preventDefault();
                        $("#" + settings.elementName).val(ui.item.value);
                    }
                }).on('input', function(){
                    const $this = $(this);
                    const val = $.trim($this.val());
                    if (!val.length){
                        const initialValue = $("#" + settings.elementName).attr('data-initialvalue');
                        $("#" + settings.elementName).val(initialValue);
                        setValueFromId(mappedUserList, initialValue);
                    }
                });
                $("#" + settings.elementName).on("changevalue", function(){
                    setValueFromId(mappedUserList, $(this).val());
                  })
            }
            else {
                const $select = $('<select/>',{
                    class: 'form-control',
                    name: settings.elementName,
                    id: settings.elementName
                });
                $this.prepend($select);
                $select.append($('<option>', {id:'myself',value:settings.userId, text:'Myself', selected:'selected'}));
                if (settings.accountId != 303) { 
                    // carried over from the cfm page logic
                    $select.append($('<option>', {value:0, text:'Guest Traveler'}));
                }
                mappedUserList.forEach(function(item){
                    // Don't add back myself or guest options if they exist in the data
                    if(item.value !== 0 && item.value !== settings.userId){
                        $select.append($('<option>', {value:item.value, text:item.label}));
                    }
                })
            }

        });
    };
})(jQuery)