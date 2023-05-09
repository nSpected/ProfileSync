"use strict";(self.webpackChunkarklight_docs=self.webpackChunkarklight_docs||[]).push([[314],{3905:(e,t,a)=>{a.d(t,{Zo:()=>p,kt:()=>v});var r=a(7294);function n(e,t,a){return t in e?Object.defineProperty(e,t,{value:a,enumerable:!0,configurable:!0,writable:!0}):e[t]=a,e}function i(e,t){var a=Object.keys(e);if(Object.getOwnPropertySymbols){var r=Object.getOwnPropertySymbols(e);t&&(r=r.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),a.push.apply(a,r)}return a}function o(e){for(var t=1;t<arguments.length;t++){var a=null!=arguments[t]?arguments[t]:{};t%2?i(Object(a),!0).forEach((function(t){n(e,t,a[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(a)):i(Object(a)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(a,t))}))}return e}function l(e,t){if(null==e)return{};var a,r,n=function(e,t){if(null==e)return{};var a,r,n={},i=Object.keys(e);for(r=0;r<i.length;r++)a=i[r],t.indexOf(a)>=0||(n[a]=e[a]);return n}(e,t);if(Object.getOwnPropertySymbols){var i=Object.getOwnPropertySymbols(e);for(r=0;r<i.length;r++)a=i[r],t.indexOf(a)>=0||Object.prototype.propertyIsEnumerable.call(e,a)&&(n[a]=e[a])}return n}var c=r.createContext({}),d=function(e){var t=r.useContext(c),a=t;return e&&(a="function"==typeof e?e(t):o(o({},t),e)),a},p=function(e){var t=d(e.components);return r.createElement(c.Provider,{value:t},e.children)},s="mdxType",u={inlineCode:"code",wrapper:function(e){var t=e.children;return r.createElement(r.Fragment,{},t)}},m=r.forwardRef((function(e,t){var a=e.components,n=e.mdxType,i=e.originalType,c=e.parentName,p=l(e,["components","mdxType","originalType","parentName"]),s=d(a),m=n,v=s["".concat(c,".").concat(m)]||s[m]||u[m]||i;return a?r.createElement(v,o(o({ref:t},p),{},{components:a})):r.createElement(v,o({ref:t},p))}));function v(e,t){var a=arguments,n=t&&t.mdxType;if("string"==typeof e||n){var i=a.length,o=new Array(i);o[0]=m;var l={};for(var c in t)hasOwnProperty.call(t,c)&&(l[c]=t[c]);l.originalType=e,l[s]="string"==typeof e?e:n,o[1]=l;for(var d=2;d<i;d++)o[d]=a[d];return r.createElement.apply(null,o)}return r.createElement.apply(null,a)}m.displayName="MDXCreateElement"},8659:(e,t,a)=>{a.r(t),a.d(t,{assets:()=>c,contentTitle:()=>o,default:()=>u,frontMatter:()=>i,metadata:()=>l,toc:()=>d});var r=a(7462),n=(a(7294),a(3905));const i={sidebar_position:8},o="DataService:DictionaryAdd(...)",l={unversionedId:"dataService/dataServiceDictionaryAdd",id:"dataService/dataServiceDictionaryAdd",title:"DataService:DictionaryAdd(...)",description:"Inserts the given value into a player's data dictionary, with a specific index.",source:"@site/docs/dataService/dataServiceDictionaryAdd.md",sourceDirName:"dataService",slug:"/dataService/dataServiceDictionaryAdd",permalink:"/ProfileSync/docs/dataService/dataServiceDictionaryAdd",draft:!1,editUrl:"https://github.com/nSpected/ProfileSync/docs/dataService/dataServiceDictionaryAdd.md",tags:[],version:"current",sidebarPosition:8,frontMatter:{sidebar_position:8},sidebar:"tutorialSidebar",previous:{title:"DataService:TableRemove(...)",permalink:"/ProfileSync/docs/dataService/dataServiceTableRemove"},next:{title:"DataService:DictionaryRemove(...)",permalink:"/ProfileSync/docs/dataService/dataServiceDictionaryRemove"}},c={},d=[{value:"Arguments",id:"arguments",level:2},{value:"Example",id:"example",level:2}],p={toc:d},s="wrapper";function u(e){let{components:t,...a}=e;return(0,n.kt)(s,(0,r.Z)({},p,a,{components:t,mdxType:"MDXLayout"}),(0,n.kt)("h1",{id:"dataservicedictionaryadd"},"DataService:DictionaryAdd(...)"),(0,n.kt)("p",null,"Inserts the given value into a player's data dictionary, with a specific index."),(0,n.kt)("h2",{id:"arguments"},"Arguments"),(0,n.kt)("ul",null,(0,n.kt)("li",{parentName:"ul"},(0,n.kt)("p",{parentName:"li"},"[ ",(0,n.kt)("strong",{parentName:"p"},"1")," ]"," ",(0,n.kt)("inlineCode",{parentName:"p"},"[Player] : Player"),", the player that will get its data changed.")),(0,n.kt)("li",{parentName:"ul"},(0,n.kt)("p",{parentName:"li"},"[ ",(0,n.kt)("strong",{parentName:"p"},"2")," ]"," ",(0,n.kt)("inlineCode",{parentName:"p"},"[DataName] : String"),", the name of the data that will be changed ","[This data needs to be a table]",".")),(0,n.kt)("li",{parentName:"ul"},(0,n.kt)("p",{parentName:"li"},"[ ",(0,n.kt)("strong",{parentName:"p"},"3")," ]"," ",(0,n.kt)("inlineCode",{parentName:"p"},"[Value] : String | Number | Table"),", the value that will be inserted into the index.")),(0,n.kt)("li",{parentName:"ul"},(0,n.kt)("p",{parentName:"li"},"[ ",(0,n.kt)("strong",{parentName:"p"},"4")," ]"," ",(0,n.kt)("inlineCode",{parentName:"p"},"[Index] : String | Number"),", the index where the value will be inserted.")),(0,n.kt)("li",{parentName:"ul"},(0,n.kt)("p",{parentName:"li"},"Returns: The new data, and the content of the index."))),(0,n.kt)("h2",{id:"example"},"Example"),(0,n.kt)("pre",null,(0,n.kt)("code",{parentName:"pre",className:"language-lua"},'local ItemToGive = {\n    ID = 391,\n    Damage = 10,\n    Attack_Speed = 1.2,\n    Price = 100\n}\n\nDataService:DictionaryAdd(Player, "Inventory", ItemToGive, ItemToGive.ID) -- ItemToGive will be inserted into the Inventory player data, in the index 391 (ItemToGive.ID).\n')),(0,n.kt)("admonition",{title:"Be Aware",type:"caution"},(0,n.kt)("p",{parentName:"admonition"},"This should only be called after the Service has been initialized.")))}u.isMDXComponent=!0}}]);