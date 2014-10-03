(function(SFDC) {

    "use strict";

    var viewProps = {
        sobject: null,
        query: "",
        maxsize: -1,
        pagesize: 2000
    };

    Polymer('force-sobject-sync', _.extend({}, viewProps, {
        ready: function() {
            var store = this.$.store;
            var that = this;
            if (SFDC.isOnline()) {
                $.when(store.cacheReady, SFDC.launcher)
                .then(function() {
                    mockSmartSyncPlugin.syncDown(
                        {type:"soql", query:that.query}, 
                        store.cache.soupName, null, 
                        function(result) {
                            that.syncId = result.syncId;
                        }
                    );
                });
            }

            document.addEventListener('sync', this.syncEvent.bind(this));
        },
        syncEvent: function(e) {
            if (this.syncId >= 0 && e.detail.syncId == this.syncId) {
                if (e.detail.status == 'DONE') this.fire('synccomplete');
            }
        }
    }));

})(window.SFDC);